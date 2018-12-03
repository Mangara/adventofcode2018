#!/usr/bin/env ruby

FABRIC_SIZE = 1000

Claim = Struct.new(:id, :x, :y, :width, :height)
CLAIM_REGEX = /\#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/ # #192 @ 780,891: 24x24

def parse_claim(line)
  parsed = line.match(CLAIM_REGEX)
  Claim.new(parsed[1].to_i, parsed[2].to_i, parsed[3].to_i, parsed[4].to_i, parsed[5].to_i)
end

def read_input(name)
  result = []
  IO.foreach(name) do |line|
    result << parse_claim(line)
  end
  result
end

def claim_foreach(claim)
  (claim.x...(claim.x + claim.width)).each do |x|
    (claim.y...(claim.y + claim.height)).each do |y|
      yield(x, y)
    end
  end
end

def apply_claim(fabric, claim)
  claim_foreach(claim) do |x, y|
    fabric[x][y] += 1
  end
end

def count_claims(claims)
  fabric = Array.new(FABRIC_SIZE) { Array.new(FABRIC_SIZE, 0) }

  claims.each do |claim|
    apply_claim(fabric, claim)
  end

  fabric
end

def fabric_foreach(fabric)
  (0...FABRIC_SIZE).each do |x|
    (0...FABRIC_SIZE).each do |y|
      yield(x, y, fabric[x][y])
    end
  end
end

def count_overlap(fabric)
  overlap = 0

  fabric_foreach(fabric) do |_, _, v|
    overlap += 1 if v > 1
  end

  overlap
end

def count_overlapping_claims(claims)
  fabric = count_claims(fabric, claims)
  count_overlap(fabric)
end

def no_overlap(fabric, claim)
  claim_foreach(claim) do |x, y|
    return false if fabric[x][y] > 1
  end
  true
end

def find_non_overlapping_claim(claims)
  fabric = count_claims(claims)
  claims.each do |claim|
    return claim.id if no_overlap(fabric, claim)
  end
end

if __FILE__ == $0
  # puts count_overlapping_claims(read_input('input.txt')) # Part 1
  puts find_non_overlapping_claim(read_input('input.txt')) # Part 2
end