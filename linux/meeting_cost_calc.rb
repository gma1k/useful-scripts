#!/usr/bin/env ruby

require 'colorize'
require 'highline/import'
require 'terminal-table'
require 'optparse'

class Meeting
  def initialize(people, rates, duration)
    @people = people
    @rates = rates
    @duration = duration
  end

  def cost
    total_cost = 0.0
    @rates.each_value do |rate|
      total_cost += rate * @duration
    end
    return total_cost
  end

  def print_details
    table = Terminal::Table.new(headings: ['Name', 'Hourly Rate', 'Cost'], align_column: [0, 2, 2])
    @rates.each do |name, rate|
      table.add_row([name, "$#{'%.2f' % rate}", "$#{'%.2f' % (rate * @duration)}"])
    end
    table.add_separator
    table.add_row(['Total', '', "$#{'%.2f' % cost}"])
    puts "The details of the meeting are:".colorize(:blue)
    puts table.to_s.colorize(:green)
  end

  def save_to_file(filename)
    File.open(filename, "a") do |file|
      file.puts "Date: #{Time.now.strftime("%Y-%m-%d")}, Time: #{Time.now.strftime("%H:%M:%S")}, People: #{@people}, Duration: #{@duration} hours"
      @rates.each do |name, rate|
        file.puts "#{name},#{rate},#{rate * @duration}"
      end
      file.puts "Total,,#{cost}"
      file.puts ""
    end
    puts "The details of the meeting have been saved to #{filename}.".colorize(:blue)
  end

  def self.get_input(options)
    people = ask("How many people are in the meeting? ", Integer) do |q|
      q.above = 0
      q.messages[:not_valid] = "Please enter a positive integer."
    end

    rates = {}

    people.times do |i|
      name = ask("What is the name of person #{i+1}? ") do |q|
        q.validate = /\A\w+\Z/
        q.messages[:not_valid] = "Please enter a valid name."
      end

      rate = ask("What is the hourly rate of #{name}? ", Float) do |q|
        q.above = 0.0
        q.messages[:not_valid] = "Please enter a positive number."
      end

      rates[name] = rate
    end

    duration = ask("How long is the meeting in hours? ", Float) do |q|
      q.above = 0.0
      q.messages[:not_valid] = "Please enter a positive number."
    end

    edit = agree("Do you want to edit or delete any input? (y/n) ") do |q|
      q.validate = /\A[yn]\Z/i
      q.messages[:not_valid] = "Please enter y or n."
    end

    while edit
      choose do |menu|
        menu.prompt = "What do you want to do? "
        menu.choice(:edit) { edit_input(rates) }
        menu.choice(:delete) { delete_input(rates) }
        menu.choice(:done) { break }
      end
      edit = agree("Do you want to edit or delete any input? (y/n) ") do |q|
        q.validate = /\A[yn]\Z/i
        q.messages[:not_valid] = "Please enter y or n."
      end
    end

    people = rates.size

    if options[:round]
      rates.each do |name, rate|
        rates[name] = rate.round
      end
    end

    return Meeting.new(people, rates, duration)
  end

  def self.edit_input(rates)
    name = ask("Who do you want to edit? ", String) do |q|
      q.in = rates.keys
      q.messages[:not_valid] = "Please enter a valid name."
    end

    rate = ask("What is the new hourly rate of #{name}? ", Float) do |q|
      q.above = 0.0
      q.messages[:not_valid] = "Please enter a positive number."
    end

    rates[name] = rate

    puts "#{name}'s hourly rate has been updated to $#{'%.2f' % rate}.".colorize(:blue)
  end

  def self.delete_input(rates)
    name = ask("Who do you want to delete? ", String) do |q|
      q.in = rates.keys
      q.messages[:not_valid] = "Please enter a valid name."
    end

    rates.delete(name)

    puts "#{name} has been deleted from the meeting.".colorize(:blue)
  end

options = {}

opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: meeting.rb [options]"

  opts.on("-r", "--round", "Round the cost to an integer value") do |r|
    options[:round] = r
  end

  opts.on("-s", "--save FILENAME", "Save the output to a file") do |s|
    options[:save] = s
  end

  opts.on("-h", "--help", "Show this help message") do
    puts opts
    exit
  end
end

begin
  opt_parser.parse!
rescue OptionParser::InvalidOption => e
  puts e
  puts opt_parser
  exit
end

meeting = Meeting.get_input(options)

meeting.print_details

if options[:save]
  meeting.save_to_file(options[:save])
end
