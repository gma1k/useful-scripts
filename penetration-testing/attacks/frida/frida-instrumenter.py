import os
import sys
import frida
import process

class Instrumenter:
    def __init__(self, script_text):
        self.sessions = []
        self.script_text = script_text
        self._device = frida.get_local_device()
        self._device.on("child-added", self._on_child_added)
        self._device.on("child-removed", self._on_child_removed)
        self._device.on("output", self._on_output)
        
    def __del__(self):
        for session in self.sessions:
            session.detach()

    def run(self, process_name):
        if not isinstance(process_name, str) or not process_name:
            print("Invalid process name")
            return
        
        proc = process.Runner(process_name, suspended = True)
        
        if not proc.create():
            print("Failed to create process")
            return
        
        process_id = proc.get_id()

        self.instrument(process_id)

        if proc:
            proc.resume()

    def instrument(self, process_id):
        if not isinstance(process_id, int) or not frida.is_process_alive(process_id):
            print("Invalid or dead process ID")
            return
        
        try:
            session = frida.attach(process_id)
        except frida.ProcessNotFoundError:
            print("Process not found")
            return
        except frida.PermissionDeniedError:
            print("Permission denied")
            return
        except Exception as e:
            print("Unexpected error: {}".format(e))
            return
        
        self.sessions.append(session)
        
        session.enable_child_gating()
        
        script = session.create_script(self.script_text)
        
        script.on('message', self.on_message)
        
        script.load()

    def on_message(self, message, data):
        if not isinstance(message, dict) or not message:
            print("Invalid message")
            return
        
        print("[{type}] => {payload}".format(**message))
        if data:
            print("Data: {}".format(data.hex()))

    def _on_child_added(self, child):
        if not isinstance(child, frida.Child) or not child:
            print("Invalid child")
            return
        
        print("New child: pid={}, parent_pid={}, origin={}, identifier={}".format(child.pid, child.parent_pid, child.origin, child.identifier))
        
        self.instrument(child.pid)

    def _on_child_removed(self, child):
        if not isinstance(child, frida.Child) or not child:
            print("Invalid child")
            return
        
        print("Child terminated: pid={}, parent_pid={}, origin={}, identifier={}".format(child.pid, child.parent_pid, child.origin, child.identifier))

    def _on_output(self, pid, fd, data):
        if not isinstance(pid, int) or not isinstance(fd, int) or not isinstance(data, bytes):
            print("Invalid output")
            return
        
        print("Output: pid={}, fd={}, data={}".format(pid, fd, repr(data))
