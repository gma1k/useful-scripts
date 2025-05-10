#include <uapi/linux/ptrace.h>
#include <linux/sched.h>

TRACEPOINT_PROBE(sched, sched_switch) {
    u32 pid = bpf_get_current_pid_tgid() >> 32;
    char comm[TASK_COMM_LEN];
    bpf_get_current_comm(&comm, sizeof(comm));
    bpf_trace_printk("%d %s\\n", pid, comm);
    return 0;
}
