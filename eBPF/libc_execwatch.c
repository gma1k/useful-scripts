#include <uapi/linux/ptrace.h>

int trace_system(struct pt_regs *ctx) {
    u64 pid_tgid = bpf_get_current_pid_tgid();
    u32 pid = pid_tgid >> 32;
    const char *cmd = (const char *)PT_REGS_PARM1(ctx);
    bpf_trace_printk("Process with PID %d called system() with command: %s\\n", pid, cmd);
    return 0;
}
