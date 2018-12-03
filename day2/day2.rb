#!/usr/bin/env ruby

def read_input(name)
  result = []
  IO.foreach(name) do |line|
    result << line.strip
  end
  result
end

def has_repeated_letter?(box_id, count)
  counts = {}

  box_id.each_char do |c|
    counts[c] ||= 0
    counts[c] += 1
  end

  return counts.any? { |char, num| num == count }
end

def compute_checksum(box_ids)
  twos = box_ids.count { |x| has_repeated_letter?(x, 2) }
  threes = box_ids.count { |x| has_repeated_letter?(x, 3) }
  twos * threes
end

def cut(string, i)
  string.slice(0, i) + string.slice(i + 1, string.length)
end

def find_similar_ids(box_ids)
  m = box_ids[0].length - 1
  (0..m).each do |i|
    to_compare = box_ids.map { |x| cut(x, i) }.sort

    to_compare.each_with_index do |x, i|
      if i < to_compare.length && x.eql?(to_compare[i + 1])
        return x
      end
    end
  end
end

if __FILE__ == $0
  # puts compute_checksum(read_input('input.txt')) # Part 1
  puts find_similar_ids(read_input('input.txt')) # Part 2
end