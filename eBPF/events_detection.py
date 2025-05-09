from bcc import BPF

bpf_source = """
#include <uapi/linux/ptrace.h>

int trace_open(struct pt_regs *ctx, const char __user *filename) {
    u32 pid = bpf_get_current_pid_tgid() >> 32;

    char comm[16];
    bpf_get_current_comm(&comm, sizeof(comm));

    bpf_trace_printk("open syscall: PID=%d COMM=%s\\n", pid, comm);
    bpf_trace_printk("    FILE: %s\\n", filename);
    return 0;
}

int trace_openat(struct pt_regs *ctx, int dfd, const char __user *filename, int flags) {
    u32 pid = bpf_get_current_pid_tgid() >> 32;

    char comm[16];
    bpf_get_current_comm(&comm, sizeof(comm));

    bpf_trace_printk("openat syscall: PID=%d COMM=%s\\n", pid, comm);
    bpf_trace_printk("    FILE: %s\\n", filename);
    return 0;
}
"""

b = BPF(text=bpf_source)

b.attach_kprobe(event="__x64_sys_open", fn_name="trace_open")
b.attach_kprobe(event="__x64_sys_openat", fn_name="trace_openat")

print("Tracing open/openat syscalls... Ctrl-C to stop.\n")

try:
    while True:
        print(b.trace_readline())
except KeyboardInterrupt:
    print("Stopping...")
