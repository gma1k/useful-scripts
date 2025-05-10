#include <uapi/linux/ptrace.h>

int trace_setuid(struct pt_regs *ctx, uid_t uid) {
    bpf_trace_printk("UID change detected: setuid(%d)\\n", uid);
    return 0;
}

int trace_setgid(struct pt_regs *ctx, gid_t gid) {
    bpf_trace_printk("GID change detected: setgid(%d)\\n", gid);
    return 0;
}
