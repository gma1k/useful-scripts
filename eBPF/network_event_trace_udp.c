#include <linux/sched.h>
#include <linux/inet.h>
#include <linux/ip.h>
#include <linux/in6.h>
#include <linux/udp.h>
#include <linux/tcp.h>

struct conn_event_t {
    u32 pid;
    u32 uid;
    u32 family;
    u32 sport;
    u32 dport;
    u64 ts;
    char task[16];
    u8 protocol;
};

BPF_PERF_OUTPUT(events);

int trace_udp_rcv(struct pt_regs *ctx, struct sock *sk) {
    struct conn_event_t event = {};

    u16 family = sk->__sk_common.skc_family;
    event.family = family;

    u16 sport = sk->__sk_common.skc_num;
    u16 dport = sk->__sk_common.skc_dport;
    event.sport = sport;
    event.dport = dport;

    event.protocol = 17;

    event.pid = bpf_get_current_pid_tgid() >> 32;
    event.uid = bpf_get_current_uid_gid();
    event.ts = bpf_ktime_get_ns();
    bpf_get_current_comm(&event.task, sizeof(event.task));

    if (event.sport != 0 && event.dport != 0 && event.pid != 0) {
        events.perf_submit(ctx, &event, sizeof(event));
    }
    return 0;
}
