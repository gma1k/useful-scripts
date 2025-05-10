#!/usr/bin/env python3

from bcc import BPF
from subprocess import check_output

libc_path = check_output("ldd /bin/ls | grep libc | awk '{print $3}'", shell=True).decode().strip()

bpf_program = """
#include <uapi/linux/ptrace.h>

int trace_system(struct pt_regs *ctx) {
    u64 pid_tgid = bpf_get_current_pid_tgid();
    u32 pid = pid_tgid >> 32;
    const char *cmd = (const char *)PT_REGS_PARM1(ctx);
    bpf_trace_printk("Process with PID %d called system() with command: %s\\n", pid, cmd);
    return 0;
}
"""

b = BPF(text=bpf_program)
b.attach_uprobe(name=libc_path, sym="system", fn_name="trace_system")

def resolve_process_name(pid, fallback=b'<...>'):
    try:
        with open(f"/proc/{pid}/comm") as f:
            return f.read().strip()
    except Exception:
        return fallback.decode() if isinstance(fallback, bytes) else fallback

print("\nMonitoring calls to system() via libc.")
print(f"Tracing system() in: {libc_path}")
print("Press Ctrl+C to stop.\n")
print("%-18s %-16s %-6s %s" % ("TIME(s)", "PROCESS", "PID", "DETAILS"))

while True:
    try:
        (task, pid, cpu, flags, ts, msg) = b.trace_fields()
        resolved_task = resolve_process_name(pid, task)
        print("%-18.9f %-16s %-6d %s" % (ts, resolved_task, pid, msg))
    except KeyboardInterrupt:
        print("\nStopped monitoring.")
        break
