#include <uapi/linux/ptrace.h>
#include <net/sock.h>

struct conn_info_t {
    u64 pid_tgid;
    u16 dport;
    u32 daddr;
};

BPF_HASH(active_connections, u64, struct conn_info_t);

TRACEPOINT_PROBE(syscalls, sys_enter_connect) {
    u64 pid_tgid = bpf_get_current_pid_tgid();
    
    struct sockaddr *uservaddr = (struct sockaddr *)args->uservaddr;
    
    if (uservaddr->sa_family == AF_INET) {
        struct sockaddr_in *sin = (struct sockaddr_in *)uservaddr;
        u16 dport = sin->sin_port;
        u32 daddr = sin->sin_addr.s_addr;
        
        struct conn_info_t conn = {};
        conn.pid_tgid = pid_tgid;
        conn.dport = ntohs(dport);
        conn.daddr = daddr;
        
        active_connections.update(&pid_tgid, &conn);
    }
    return 0;
}
