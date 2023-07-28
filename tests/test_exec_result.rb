#!/usr/bin/env ruby

module ShellHelper
  def test(command)
    `#{command} 2> /dev/null`
    $?.success?
  end

  def execute(command, raise_on_error = true)
    result = `#{command}`
    raise "execute command failed\n" if (not $?.success?) and raise_on_error
    return $?.success?
  end

  def print_exit(message)
    print "#{message}\n"
    exit
  end

  module_function :execute, :print_exit, :test
end
