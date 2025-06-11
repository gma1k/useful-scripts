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
