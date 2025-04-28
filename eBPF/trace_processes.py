#!/usr/bin/env python3

from bcc import BPF
import time

bpf_program = """
#include <uapi/linux/ptrace.h>
#include <linux/sched.h>

TRACEPOINT_PROBE(sched, sched_switch) {
    u32 pid = bpf_get_current_pid_tgid() >> 32;
    char comm[TASK_COMM_LEN];
    bpf_get_current_comm(&comm, sizeof(comm));
    bpf_trace_printk("%d %s\\n", pid, comm);
    return 0;
}
"""

b = BPF(text=bpf_program)

print("Tracing running processes for 15 seconds...")
print("%-8s %-16s" % ("PID", "COMMAND"))
print("=" * 26)

start_time = time.time()

try:
    while True:
        current_time = time.time()
        if current_time - start_time > 15:
            break
        try:
            (task, pid, cpu, flags, ts, msg) = b.trace_fields(nonblocking=True)
            if msg is None:
                time.sleep(0.01)
                continue
            fields = msg.strip().split(b' ', 1)
            if len(fields) != 2:
                continue
            pid_str, comm = fields
            print(f"{int(pid_str):<8d} {comm.decode('utf-8'):<16s}")
            time.sleep(0.1)
        except ValueError:
            continue
except KeyboardInterrupt:
    print("\nInterrupted by user. Exiting...")

print("\nDone tracing after 15 seconds.")
