#!/usr/bin/env ruby
require "set"

def read_input(name)
  result = []
  IO.foreach(name) do |line|
    result << line.to_i
  end
  result
end

def find_first_repeat(sequence)
  freq = 0
  seen = Set.new

  sequence.cycle do |x|
    freq += x
    return freq unless seen.add?(freq)
  end
end

if __FILE__ == $0
  puts find_first_repeat(read_input('input.txt'))
end