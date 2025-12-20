import os
import sys    
import argparse
import code

def auto_int(x):
    return int(x, 0)

def error(message):
    print("Error: {}".format(message))
    sys.exit(1)

def on_message(message, data):
    if not isinstance(message, dict) or not message:
        error("Invalid message")
    
    print("[{type}] => {payload}".format(**message))
    if data:
        print("Data: {}".format(data.hex()))

def on_child(child):
    if not isinstance(child, frida.Child) or not child:
        error("Invalid child")
    
    print("Child: pid={}, parent_pid={}, origin={}, identifier={}".format(child.pid, child.parent_pid, child.origin, child.identifier))

def on_output(pid, fd, data):
    if not isinstance(pid, int) or not isinstance(fd, int) or not isinstance(data, bytes):
        error("Invalid output")
    
    print("Output: pid={}, fd={}, data={}".format(pid, fd, repr(data)))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='run.py [-n <process name>] [-p <process id>] [<presets>, ...]')
    
    parser.add_argument("-n", "--process_name", dest = "process_name", default = "", metavar = "PROCESS_NAME", help = "Set process name to start")
    parser.add_argument('-p', dest = "process_id", default = 0, type = auto_int)
    parser.add_argument('script_filenames', metavar='SCRIPT_FILENAMES', nargs='+', help = "Set script file names")
    
    args = parser.parse_args()

    script_text = ''
    
    for script_filename in args.script_filenames:
        try:
            with open(script_filename, 'r') as fd:
                script_text += fd.read() + '\n'
        except FileNotFoundError:
            error("File not found: {}".format(script_filename))
        except PermissionError:
            error("Permission denied: {}".format(script_filename))
        except Exception as e:
            error("Unexpected error: {}".format(e))

    code_instrumenter = code.Instrumenter(script_text)

    if args.process_name:
        code_instrumenter.run(args.process_name)
    else:
        if args.process_id:
            code_instrumenter.instrument(args.process_id)
        else:
            error("No process name or ID given")

    print("[!] Ctrl+D on UNIX, Ctrl+Z on Windows/cmd.exe to detach from instrumented program.\n\n")
    
    sys.stdin.read()
