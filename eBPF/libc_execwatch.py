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

print("\n Monitoring suspicious command executions via system()")
print(f" Tracing libc's system() function in: {libc_path}")
print(" Press Ctrl+C to stop.\n")
print("%-18s %-16s %-6s %s" % ("TIME(s)", "PROCESS", "PID", "DETAILS"))

while True:
    try:
        (task, pid, cpu, flags, ts, msg) = b.trace_fields()
        print("%-18.9f %-16s %-6d %s" % (ts, task, pid, msg))
    except KeyboardInterrupt:
        print("\n Exiting monitoring.")
        break
