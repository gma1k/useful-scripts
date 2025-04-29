#!/usr/bin/env python3

from bcc import BPF
import time

bpf_text = """
#include <uapi/linux/ptrace.h>
#include <net/sock.h>
#include <bcc/proto.h>

BPF_HASH(active_connections, u32, u16);

int trace_connect(struct pt_regs *ctx, struct sock *sk) {
    u32 pid = bpf_get_current_pid_tgid();
    u16 dport = 0;
    
    bpf_probe_read_kernel(&dport, sizeof(dport), &sk->__sk_common.skc_dport);
    dport = ntohs(dport);
    
    active_connections.update(&pid, &dport);
    return 0;
}
"""

b = BPF(text=bpf_text)
b.attach_kprobe(event="tcp_v4_connect", fn_name="trace_connect")

print("Monitoring TCP connections...")
try:
    while True:
        time.sleep(1)
        for k, v in b["active_connections"].items():
            print(f"PID {k.value} connected to port {v.value}")
        b["active_connections"].clear()
except KeyboardInterrupt:
    pass
