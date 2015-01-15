class Array
  def unique_values
    unique_elements = []
    each do |element|
      unique_elements << element unless unique_elements.include?(element)
    end

    unique_elements
  end
end

class NumberSet
  include Enumerable

  def initialize
    @elements = []
  end

  def size
    @elements.size
  end

  def empty?
    @elements.empty?
  end

  def <<(new_number)
    @elements.push(new_number)
    @elements = @elements.unique_values #uniq

    self
  end

  def to_a
    @elements
  end

  def each
    @elements.each do |element|
      yield(element)
    end

    self
  end

  def [](filter)
    result = NumberSet.new
    filter.each(@elements) { |element| result << element }

    result
  end
end

module SharedMethods
  attr_reader :block

  def each(elements)
    @filtered = []
    elements.each do |elem|
      if block.call(elem) == true & not(@filtered.include?(elem))
        yield(elem)
      end
    end

    @filtered
  end

  def &(filter)
    Filter.new { |n| self.block.call(n) and filter.block.call(n) }
  end

  def |(filter)
    Filter.new { |n| self.block.call(n) or filter.block.call(n) }
  end
end

class Filter
  include SharedMethods

  def initialize(&block)
    @block = block
    @filtered = []
    @input = []
  end
end

class SignFilter
  include SharedMethods

  def initialize(polarity)
    @block = case polarity
               when :positive     then ->(n) { n > 0 }
               when :non_positive then ->(n) { n <= 0 }
               when :negative     then ->(n) { n < 0 }
               when :non_negative then ->(n) { n >= 0 }
             end
    @filtered = []
    @input = []
  end
end

class TypeFilter
  include SharedMethods

  def initialize(type)
    @block = case type
               when :integer then ->(n) { n.integer? }
               when :real    then ->(n) { n.real? and not(n.integer?) }
               when :complex then ->(n) { n.is_a?(Complex) }
             end
    @input = []
    @filtered = []
  end
end
