#include <uapi/linux/ptrace.h>
#include <net/sock.h>
#include <linux/tcp.h>
#include <bcc/proto.h>

struct conn_info_t {
    u32 pid;
    char comm[TASK_COMM_LEN];
    u32 saddr;
    u32 daddr;
    u16 sport;
    u16 dport;
};

BPF_HASH(active_conns, u64, struct conn_info_t);

int trace_tcp_accept(struct pt_regs *ctx, struct sock *sk) {
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
    
    conn.sport = ntohs(conn.sport);
    conn.dport = ntohs(conn.dport);

    active_conns.update(&pid_tgid, &conn);
    return 0;
}
