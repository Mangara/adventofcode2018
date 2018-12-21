#!/usr/bin/env ruby
require 'date'

Event = Struct.new(:date_time, :event)
EVENT_REGEX = /\[(\d\d\d\d-\d\d-\d\d\ \d\d:\d\d)\] (.*)/ # [1518-07-13 00:01] Guard #2083 begins shift

def parse_event(line)
  parsed = line.match(EVENT_REGEX)
  Event.new(DateTime.parse(parsed[1]), parsed[2])
end

def read_input(name)
  result = []
  IO.foreach(name) do |line|
    result << parse_event(line)
  end
  result
end

Sleep = Struct.new(:date, :id, :sleep, :wake)
SHIFT_REGEX = /Guard \#(\d+) begins shift/ # Guard #99 begins shift
SLEEP_REGEX = /falls asleep/
WAKE_REGEX  = /wakes up/

def events_to_sleeps(events)
  current_guard = nil
  sleep_time = nil
  sleeps = []

  events.each do |event|
    if event.event.match?(SHIFT_REGEX)
      current_guard = event.event.match(SHIFT_REGEX).captures.first
    elsif event.event.match?(SLEEP_REGEX)
      sleep_time = event.date_time.strftime('%M').to_i
    elsif event.event.match?(WAKE_REGEX)
      wake = event.date_time
      sleeps << Sleep.new(wake.to_date, current_guard, sleep_time, wake.strftime('%M').to_i)
    else
      puts('==== NO MATCH ====')
    end
  end

  sleeps
end

def sleep_time(sleeps)
  sleep_time = {}

  sleeps.each do |sleep|
    sleep_time[sleep.id] ||= 0
    sleep_time[sleep.id] += sleep.wake - sleep.sleep
  end

  sleep_time
end

def find_most_sleepy_guard(sleep_time)
  sleep_time.max_by { |_, v| v }[0]
end

def minutes_asleep(sleeps, guard)
  minutes_asleep = Array.new(60, 0)

  sleeps.each do |sleep|
    next if sleep.id != guard

    (sleep.sleep...sleep.wake).each do |minute|
      minutes_asleep[minute] += 1
    end
  end

  minutes_asleep
end

def find_most_sleepy_minute(sleeps, guard)
  minutes_asleep(sleeps, guard).each_with_index.max[1]
end

def strategy1(events)
  sorted = events.sort_by { |event| event.date_time }
  sleeps = events_to_sleeps(sorted)
  sleep_time = sleep_time(sleeps)
  sleepy_guard = find_most_sleepy_guard(sleep_time)
  sleepy_minute = find_most_sleepy_minute(sleeps, sleepy_guard)
  sleepy_guard.to_i * sleepy_minute
end

def guards(sleeps)
  sleeps.map(&:id).uniq
end

def minutes_asleep_per_guard(sleeps)
  result = {}
  guards(sleeps).each do |guard|
    result[guard] = minutes_asleep(sleeps, guard)
  end
  result
end

def most_sleepy_guard_minute(guard_sleeps)
  max_minute = guard_sleeps.map do |guard, minutes|
    [guard] + minutes.each_with_index.max
  end
  max = max_minute.max_by { |mm| mm[1] }
  [max[0], max[2]]
end

def strategy2(events)
  sorted = events.sort_by { |event| event.date_time }
  sleeps = events_to_sleeps(sorted)
  guard_sleeps = minutes_asleep_per_guard(sleeps)
  max_guard, max_minute = most_sleepy_guard_minute(guard_sleeps)
  max_guard.to_i * max_minute
end

if __FILE__ == $0
  # puts strategy1(read_input('input.txt')) # Part 1
  puts strategy2(read_input('input.txt')) # Part 2
end