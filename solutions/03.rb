module RBFS
  module Helper
    def Helper.string_number(string)
      string.include?(".") ? string.to_f : string.to_i
    end

    def Helper.generate_files(string_data)
      file_count = string_data.to_i
      files = []
      data = string_data[file_count.to_s.length + 1 ... string_data.length]
      0.upto(file_count - 1) do
        file_info = read_file(data)
        files << file_info[0..1]
        data = file_info[2]
      end

      [files, data]
    end

    def Helper.generate_directories(string_data)
      dir_count = string_data.to_i
      string_directories = []
      while dir_count > 0 do
        info = read_directory(string_data[dir_count.to_s.length + 1...string_data.size])
        string_directories << info[0..1]
        string_data = info[2]
        dir_count = dir_count - 1
      end

      string_directories
    end

    def Helper.read_file(data)
      name = data.partition(":")[0]
      length = data[name.size + 1 ...data.length].to_i
      left = name.to_s.length + length.to_s.length + 2
      right = name.to_s.length + length.to_s.length + length + 2
      content = data[left...right]

      [name, RBFS::File.parse(content),
       data[name.to_s.length + length.to_s.length + length + 2...data.size]]
    end

    def Helper.read_directory(string_data)
      name = string_data.partition(":")[0]
      length = string_data[name.to_s.length + 1...string_data.size].to_i
      left = name.to_s.length + length.to_s.size + 2
      right = name.to_s.length + length.to_s.size + length
      content = string_data[left...right]

      [name,
       content,
       string_data[name.to_s.length + length.to_s.size + length...string_data.size]]
    end
  end

  class File
    include Helper
    attr_reader :data_type
    attr_accessor :data

    def initialize(file = nil)
      @data = file
      @data_type = determine_type
    end

    def determine_type
      case @data
      when String     then :string
      when Symbol     then :symbol
      when Numeric    then :number
      when TrueClass  then :boolean
      when FalseClass then :boolean
      when NilClass   then :nil
      end
    end

    def serialize
      @data_type = determine_type
      "#@data_type:#@data"
    end

    def size
      serialize.length
    end

    def self.parse(serialized)
      file = case serialized.partition(":")[0].to_sym
             when :string  then serialized[7..serialized.length]
             when :symbol  then serialized[7..serialized.length].to_sym
             when :number  then Helper.string_number(serialized[7..serialized.length])
             when :boolean then serialized[8..serialized.length] == "true"
             when :nil     then nil
             end

      RBFS::File.new(file)
    end
  end

  class Directory
    include Helper
    attr_reader :files
    attr_reader :directories

    def initialize(directories = {})
      @files = {}
      @directories = directories
    end

    def add_file(name, file)
      @files[name] = file unless name.include?(":")
    end

    def add_directory(name, directory = RBFS::Directory.new)
      corectness = name.include?(":")
      @directories[name] = directory unless corectness
    end

    def [](name)
      if @directories.include?(name)
        @directories[name]
      elsif @files.include?(name)
        file = RBFS::File.new
        file.data = @files[name].data
        file.determine_type
        file
      end
    end

    def serialize
      files = @files.to_a
                    .map { |n, f| n + ":" + f.size.to_s + ":" + f.serialize }
                    .reduce("") { |a, b| a + b }
      dirs = @directories.to_a
                         .map { |n, d| n + ":" + d.size.to_s + ":" + d.serialize }
                         .reduce("") { |a, b| a + b }

      "#{@files.count}:#{files}#{@directories.count}:#{dirs}"
    end

    def size
      serialize.length
    end

    def self.parse(string_data)
      result = RBFS::Directory.new
      files = Helper.generate_files(string_data)
      files[0].each { |name, file| result.add_file(name, file) }
      string_directories = Helper.generate_directories(files[1])
      string_directories.each { |name, dir| result.add_directory(name, parse(dir)) }
      result
    end
  end
end
