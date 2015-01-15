def sequence(first, second, n)
  (n - 1).times do
    second = first + second
    first = second - first
  end
  first
end

def series(name, n)
  case name
    when "fibonacci" then sequence(1, 1, n)
    when "lucas"     then sequence(2, 1, n)
    when "summed"    then sequence(1, 1, n) + sequence(2, 1, n)
  end
end
