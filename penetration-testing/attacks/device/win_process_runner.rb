#!/usr/bin/env ruby

require 'ffi'

module Kernel32
  extend FFI::Library
  ffi_lib 'kernel32'
  ffi_convention :stdcall

  DEBUG_PROCESS = 0x00000001
  CREATE_SUSPENDED = 0x00000004
  CREATE_NEW_CONSOLE = 0x00000010

  typedef :ulong, :dword
  typedef :ushort, :word
  typedef :pointer, :lpbyte
  typedef :pointer, :lptstr
  typedef :pointer, :handle

  class StartupInfo < FFI::Struct
    layout(
      :cb, :dword,
      :lpReserved, :lptstr,
      :lpDesktop, :lptstr,
      :lpTitle, :lptstr,
      :dwX, :dword,
      :dwY, :dword,
      :dwXSize, :dword,
      :dwYSize, :dword,
      :dwXCountChars, :dword,
      :dwYCountChars, :dword,
      :dwFillAttribute,:dword,
      :dwFlags, :dword,
      :wShowWindow, :word,
      :cbReserved2, :word,
      :lpReserved2, :lpbyte,
      :hStdInput, :handle,
      :hStdOutput, :handle,
      :hStdError, :handle
    )
  end

  class ProcessInformation < FFI::Struct
    layout(
      :hProcess, :handle,
      :hThread, :handle,
      :dwProcessId, :dword,
      :dwThreadId, :dword
    )
  end

  attach_function 'CreateProcessW', [:lptstr, :lptstr, :pointer, 
    pointer:bool,:dword,:pointer,:lptstr,:pointer,:pointer],:bool
  attach_function 'GetLastError', [],:dword
  attach_function 'ResumeThread', [:handle],:dword
end

class Runner
  def initialize(command_line, debug = false, show = true, suspended = false)
    @command_line = command_line.encode('UTF-16LE')
    @error_code = 0

    @creation_flags = 0
    @creation_flags |= Kernel32::DEBUG_PROCESS if debug
    @creation_flags |= Kernel32::CREATE_SUSPENDED if suspended

    @startup_info = Kernel32::StartupInfo.new
    @startup_info[:cb] = @startup_info.size
    @startup_info[:wShowWindow] = show ? 1:0
    @startup_info[:dwFlags] = 0x1

    @process_info = Kernel32::ProcessInformation.new
  end

  def create
    puts "Creating process: #{@command_line}"
    if not Kernel32.CreateProcessW(
        nil,
        @command_line,
        nil,
        nil,
        false,
        @creation_flags,
        nil,
        nil,
        @startup_info.pointer,
        @process_info.pointer)
      @error_code = Kernel32.GetLastError()
      puts "[*] Error: 0x%08x." % (@error_code)
      return false
    end
    return true
  end

  def get_id
    return @process_info[:dwProcessId]
  end

  def resume
    Kernel32.ResumeThread(@process_info[:hThread])
  end
end

if __FILE__ == $0
  process = Runner.new("C:\\WINDOWS\\system32\\notepad.exe", suspended: true)
  process.create()
  puts process.get_id()
  sleep(5)
  process.resume()
end
