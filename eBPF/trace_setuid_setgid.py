from bcc import BPF

program = """
#include <uapi/linux/ptrace.h>

int trace_setuid(struct pt_regs *ctx, uid_t uid) {
    bpf_trace_printk("UID change detected: setuid(%d)\\n", uid);
    return 0;
}

int trace_setgid(struct pt_regs *ctx, gid_t gid) {
    bpf_trace_printk("GID change detected: setgid(%d)\\n", gid);
    return 0;
}
"""

b = BPF(text=program)

# Use working syscalls for 64-bit
b.attach_kprobe(event="__x64_sys_setuid", fn_name="trace_setuid")
b.attach_kprobe(event="__x64_sys_setgid", fn_name="trace_setgid")

print("Monitoring setuid/setgid syscalls... Press Ctrl-C to exit.")
try:
    b.trace_print()
except KeyboardInterrupt:
    print("\nDetaching and exiting.")
