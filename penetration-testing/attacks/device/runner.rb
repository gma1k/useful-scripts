require 'os'
require 'sys'
require 'argparse'
require 'code'

def auto_int(x)
  return Integer(x)
end

def error(message)
  puts "Error: #{message}"
  exit(1)
end

def on_message(message, data)
  if not message.is_a?(Hash) or message.empty?
    error("Invalid message")
  end
  
  puts "[#{message[:type]}] => #{message[:payload]}"
  if data
    puts "Data: #{data.unpack('H*')}"
  end
end

def on_child(child)
  if not child.is_a?(Frida::Child) or child.nil?
    error("Invalid child")
  end
  
  puts "Child: pid=#{child.pid}, parent_pid=#{child.parent_pid}, origin=#{child.origin}, identifier=#{child.identifier}"
end

def on_output(pid, fd, data)
  if not pid.is_a?(Integer) or not fd.is_a?(Integer) or not data.is_a?(String)
    error("Invalid output")
  end
  
  puts "Output: pid=#{pid}, fd=#{fd}, data=#{data.inspect}"
end

if __FILE__ == $0
  parser = ArgumentParser.new(description: 'run.rb [-n <process name>] [-p <process id>] [<presets>, ...]')
  
  parser.add_argument("-n", "--process_name", dest: "process_name", default: "", metavar: "PROCESS_NAME", help: "Set process name to start")
  parser.add_argument('-p', dest: "process_id", default: 0, type: method(:auto_int))
  parser.add_argument('script_filenames', metavar: 'SCRIPT_FILENAMES', nargs: '+', help: "Set script file names")
  
  args = parser.parse_args()

  script_text = ''
  
  args.script_filenames.each do |script_filename|
    begin
      File.open(script_filename, 'r') do |fd|
        script_text += fd.read + "\n"
      end
    rescue Errno::ENOENT
      error("File not found: #{script_filename}")
    rescue Errno::EACCES
      error("Permission denied: #{script_filename}")
    rescue Exception => e
      error("Unexpected error: #{e}")
    end
  end

  code_instrumenter = Code::Instrumenter.new(script_text)

  if args.process_name != ""
    code_instrumenter.run(args.process_name)
  else
    if args.process_id != 0
      code_instrumenter.instrument(args.process_id)
    else
      error("No process name or ID given")
    end
  end

  puts "[!] Ctrl+D on UNIX, Ctrl+Z on Windows/cmd.exe to detach from instrumented program.\n\n"
  
  STDIN.read()
end
