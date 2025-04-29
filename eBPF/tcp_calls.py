#!/usr/bin/env python3

from bcc import BPF
import ctypes
import time
import struct
import socket

bpf_text = """
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
"""

b = BPF(text=bpf_text)

print("[*] Monitoring TCP connect() calls (Ctrl+C to stop)")

try:
    while True:
        time.sleep(1)
        
        for k, v in b["active_connections"].items():
            pid = k.value >> 32
            tgid = k.value & 0xFFFFFFFF
            dport = v.dport
            
            daddr = socket.inet_ntoa(struct.pack("!I", v.daddr))
            
            print(f"[+] PID {pid} (TGID {tgid}) → {daddr}:{dport}")
        
        b["active_connections"].clear()

except KeyboardInterrupt:
    print("\n[*] Stopping...")
    exit()
