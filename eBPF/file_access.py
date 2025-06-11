#!/usr/bin/env python3

from bcc import BPF

bpf_code = """
#include <uapi/linux/ptrace.h>

#define TASK_COMM_LEN 16

TRACEPOINT_PROBE(syscalls, sys_enter_openat) {
    u32 pid = bpf_get_current_pid_tgid() >> 32;
    char comm[TASK_COMM_LEN];
    bpf_get_current_comm(&comm, sizeof(comm));
    bpf_trace_printk("Proc %s (%d) open: ", comm, pid);
    bpf_trace_printk("%s\\n", args->filename);
    return 0;
}
"""

b = BPF(text=bpf_code)
print("Monitoring file opens... Press Ctrl-C to stop.")

try:
    while True:
        line = b.trace_readline().decode("utf-8", errors="replace").strip()
        if "bpf_trace_printk:" in line:
            msg = line.split("bpf_trace_printk:")[1].strip()
            print(msg)
except KeyboardInterrupt:
    print("\nStopped.")
