#!/usr/bin/env python3

from bcc import BPF
from socket import inet_ntop, AF_INET
from struct import pack
import ctypes

bpf_program = """
#include <uapi/linux/ptrace.h>
#include <net/sock.h>
#include <linux/in.h>
#include <linux/in6.h>

struct data_t {
    u32 pid;
    u32 saddr;
    u32 daddr;
    u16 sport;
    u16 dport;
    char comm[TASK_COMM_LEN];
};

BPF_PERF_OUTPUT(events);

int trace_connect(struct pt_regs *ctx, struct sock *sk) {
    u16 family = sk->__sk_common.skc_family;
    if (family == AF_INET) {
        struct data_t data = {};
        data.pid = bpf_get_current_pid_tgid() >> 32;
        data.saddr = sk->__sk_common.skc_rcv_saddr;
        data.daddr = sk->__sk_common.skc_daddr;
        data.sport = sk->__sk_common.skc_num;
        data.dport = sk->__sk_common.skc_dport;
        data.dport = ntohs(data.dport);
        bpf_get_current_comm(&data.comm, sizeof(data.comm));
        events.perf_submit(ctx, &data, sizeof(data));
    }
    return 0;
}
"""

b = BPF(text=bpf_program)
b.attach_kprobe(event="tcp_connect", fn_name="trace_connect")

class Data(ctypes.Structure):
    _fields_ = [
        ("pid", ctypes.c_uint),
        ("saddr", ctypes.c_uint),
        ("daddr", ctypes.c_uint),
        ("sport", ctypes.c_ushort),
        ("dport", ctypes.c_ushort),
        ("comm", ctypes.c_char * 16)
    ]

def print_event(cpu, data, size):
    event = ctypes.cast(data, ctypes.POINTER(Data)).contents
    print(f"[{event.comm.decode()}] PID {event.pid} {inet_ntop(AF_INET, pack('I', event.saddr))}:{event.sport} -> {inet_ntop(AF_INET, pack('I', event.daddr))}:{event.dport}")

print("Tracing TCP connections... Ctrl-C to stop.")
b["events"].open_perf_buffer(print_event)
try:
    while True:
        b.perf_buffer_poll()
except KeyboardInterrupt:
    print("Stopping trace.")
