#!/usr/bin/env ruby

require 'optparse'
require 'code'

def auto_int(x)
  Integer(x, 0)
end

def parse_options
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: run.rb [-n PROCESS_NAME] [-p PROCESS_ID] SCRIPT_FILENAMES..."

    opts.on("-n", "--process_name PROCESS_NAME", "Set process name to start") do |n|
      options[:process_name] = n
    end

    opts.on("-p", "--process_id PROCESS_ID", "Set process ID to instrument") do |p|
      options[:process_id] = auto_int(p)
    end

    opts.on("-h", "--help", "Prints this help") do
      puts opts
      exit
    end
  end.parse!

  options[:script_filenames] = ARGV

  if options[:script_filenames].empty?
    raise OptionParser::MissingArgument, "SCRIPT_FILENAMES"
  end

  return options
end

options = parse_options

script_text = ""
options[:script_filenames].each do |filename|
  File.open(filename, "r") do |file|
    script_text += file.read + "\n"
  end
end

code_instrumenter = Code::Instrumenter.new(script_text)

if options[:process_name]
  code_instrumenter.run(options[:process_name])
else
  code_instrumenter.instrument(options[:process_id])
end

puts "[!] Ctrl+D on UNIX, Ctrl+Z on Windows/cmd.exe to detach from instrumented program.\n\n"
STDIN.read
