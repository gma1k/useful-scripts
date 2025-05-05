#include <linux/bpf.h>
#include <linux/ptrace.h>
#include <net/sock.h>
#include <linux/tcp.h>
#include <linux/version.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

#define TASK_COMM_LEN 16

struct conn_info_t {
    u32 pid;
    char comm[TASK_COMM_LEN];
    u32 saddr;
    u32 daddr;
    u16 sport;
    u16 dport;
};

struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __type(key, u64);
    __type(value, struct conn_info_t);
    __uint(max_entries, 10240);
} active_conns SEC(".maps");

SEC("kprobe/tcp_v4_do_rcv")
int trace_tcp_accept(struct pt_regs *ctx) {
    struct sock *sk = (struct sock *)PT_REGS_PARM1(ctx);
    
    if (sk->__sk_common.skc_family != AF_INET)
        return 0;

    struct conn_info_t conn = {};
    u64 pid_tgid = bpf_get_current_pid_tgid();
    conn.pid = pid_tgid >> 32;
    bpf_get_current_comm(&conn.comm, sizeof(conn.comm));

    conn.saddr = sk->__sk_common.skc_rcv_saddr;
    conn.daddr = sk->__sk_common.skc_daddr;
    conn.sport = sk->__sk_common.skc_num;
    conn.dport = sk->__sk_common.skc_dport;
    
    conn.sport = bpf_ntohs(conn.sport);
    conn.dport = bpf_ntohs(conn.dport);

    bpf_map_update_elem(&active_conns, &pid_tgid, &conn, BPF_ANY);
    return 0;
}

char _license[] SEC("license") = "GPL";
