#!/usr/bin/env ruby

def get_positive_integer(prompt)
  loop do
    print prompt
    input = gets.chomp.to_i
    if input > 0
      return input
    else
      puts "Please enter a positive integer."
    end
  end
end

def get_positive_float(prompt)
  loop do
    print prompt
    input = gets.chomp.to_f
    if input > 0.0
      return input
    else
      puts "Please enter a positive number."
    end
  end
end

def calculate_meeting_cost(people, rates, duration)
  total_cost = 0.0
  people.times do |i|
    total_cost += rates[i] * duration
  end
  return total_cost
end

people = get_positive_integer("How many people are in the meeting? ")

rates = []

people.times do |i|
  rate = get_positive_float("What is the hourly rate of person #{i+1}? ")
  rates << rate
end

duration = get_positive_float("How long is the meeting in hours? ")

total_cost = calculate_meeting_cost(people, rates, duration)
puts "The total cost of the meeting is $%.2f" % total_cost
