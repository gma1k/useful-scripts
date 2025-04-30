#!/usr/bin/env python3

from bcc import BPF
import ctypes
import time
import struct
import socket
from collections import defaultdict

bpf_text = """
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
"""

b = BPF(text=bpf_text,
        cflags=["-Wno-macro-redefined",
                "-Wno-return-type",
                "-Wno-address-of-packed-member"])

b.attach_kprobe(event="tcp_v4_do_rcv", fn_name="trace_tcp_accept")

print("[*] Monitoring all active TCP connections (Ctrl+C to stop)\n")
print("{:6} {:16} {:20} {:20} {}".format(
    "PID", "Process", "Local", "Remote", "State"
))

try:
    while True:
        if int(time.time()) % 5 == 0:
            print("\n{:-<80}".format(""))
            print("{:6} {:16} {:20} {:20} {}".format(
                "PID", "Process", "Local", "Remote", "State"
            ))

        conns_by_process = defaultdict(list)
        for k, v in b["active_conns"].items():
            if v.sport == 0 and v.dport == 0:
                continue
                
            local_ip = socket.inet_ntoa(struct.pack("!I", v.saddr)) if v.saddr else "0.0.0.0"
            remote_ip = socket.inet_ntoa(struct.pack("!I", v.daddr)) if v.daddr else "0.0.0.0"
            
            conn_str = f"{local_ip}:{v.sport} -> {remote_ip}:{v.dport}"
            conns_by_process[(v.pid, v.comm.decode())].append(conn_str)

        for (pid, comm), conns in conns_by_process.items():
            for i, conn in enumerate(conns):
                if i == 0:
                    print(f"{pid:<6} {comm[:16]:16} {conn.split('->')[0]:20} {conn.split('->')[1]:20} ESTABLISHED")
                else:
                    print(f"{'':6} {'':16} {conn.split('->')[0]:20} {conn.split('->')[1]:20} ESTABLISHED")

        time.sleep(1)

except KeyboardInterrupt:
    print("\n[*] Stopping monitor...")
    exit()
