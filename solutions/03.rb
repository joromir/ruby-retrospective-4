module RBFS
  class Parser
    def initialize(string_data)
      @string_data = string_data
    end

    def parse_list
      objects_count, @string_data = @string_data.split(':', 2)
      objects_count.to_i.times do
        name, length, rest = @string_data.split(':', 3)
        yield name, rest[0...length.to_i]
        @string_data = rest[length.to_i..-1]
      end
    end
  end

  class File
    attr_accessor :data

    def initialize(data = nil)
      @data = data
    end

    def data_type
      case @data
        when String                then :string
        when Symbol                then :symbol
        when Fixnum, Float         then :number
        when TrueClass, FalseClass then :boolean
        when NilClass              then :nil
      end
    end

    def serialize
      "#{data_type}:#{data}"
    end

    def self.parse(string_data)
      data_type, data = string_data.split(':', 2)
      data = case data_type
               when 'string'  then data
               when 'symbol'  then data.to_sym
               when 'number'  then data.to_f
               when 'boolean' then data == 'true'
             end
      File.new(data)
    end
  end

  class Directory
    attr_reader :files, :directories

    def self.parse(string_data)
      directory = Directory.new
      parser = Parser.new(string_data)
      parser.parse_list do |name, data|
        directory.add_file(name, File.parse(data))
      end
      parser.parse_list do |name, data|
        directory.add_directory(name, Directory.parse(data))
      end
      directory
    end

    def initialize
      @files = {}
      @directories = {}
    end

    def add_file(name, file)
      @files[name] = file
    end

    def add_directory(name, directory = Directory.new)
      @directories[name] = directory
    end

    def [](name)
      @directories[name] || @files[name]
    end

    def serialize
      "#{serialize_list(@files)}#{serialize_list(@directories)}"
    end

    private

    def serialize_list(objects)
      serialized_objects = objects.map do |name, object|
        serialized_object = object.serialize
        "#{name}:#{serialized_object.length}:#{serialized_object}"
      end
      "#{objects.count}:#{serialized_objects.join('')}"
    end
  end
end
