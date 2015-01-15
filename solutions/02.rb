class NumberSet
  include Enumerable

  def initialize(input = [])
    @elements = input.uniq
  end

  def size
    @elements.size
  end

  def empty?
    @elements.empty?
  end

  def <<(number)
    @elements << number unless @elements.include?(number)
  end

  def to_a
    @elements
  end

  def each(&block)
    @elements.each(&block)
  end

  def [](filter)
    NumberSet.new @elements.select { |x| filter.call(x) }
  end
end

class Filter
  def initialize(&block)
    @block = block
  end

  def &(other)
    Filter.new { |x| @block.call(x) and other.call(x) }
  end

  def |(other)
    Filter.new { |x| @block.call(x) or other.call(x) }
  end

  def call(p)
    @block.call(p)
  end
end

class TypeFilter < Filter
  def initialize(type)
    case type
      when :integer then super() { |x| x.is_a? Integer }
      when :complex then super() { |x| x.is_a? Complex }
      when :real    then super() { |x| x.is_a? Float or x.is_a? Rational }
    end
  end
end

class SignFilter < Filter
  def initialize(polarity)
    case polarity
      when :non_positive then super() { |x| x <= 0 }
      when :non_negative then super() { |x| x >= 0 }
      when :positive     then super() { |x| x > 0 }
      when :negative     then super() { |x| x < 0 }
    end
  end
end
