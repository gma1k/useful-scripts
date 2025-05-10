#!/usr/bin/env python3

from bcc import BPF

bpf_program = """
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
"""

b = BPF(text=bpf_program)
b.attach_kprobe(event="__udp4_lib_rcv", fn_name="trace_udp_rcv")
b.attach_kprobe(event="__udp6_lib_rcv", fn_name="trace_udp_rcv")

def print_event(cpu, data, size):
    event = b["events"].event(data)
    pid = event.pid
    uid = event.uid
    family = event.family
    sport = event.sport
    dport = event.dport
    ts = event.ts
    task = event.task.decode('utf-8')
    protocol = event.protocol

    protocol_str = "UDP"
    family_str = "IPv4" if family == 2 else "IPv6" if family == 10 else "Unknown"
    
    if sport != 0 and dport != 0 and pid != 0:
        print(f"PID={pid} UID={uid} Family={family_str} Protocol={protocol_str} "
              f"Sport={sport} Dport={dport} TS={ts} Task={task}")

b["events"].open_perf_buffer(print_event)

try:
    while True:
        b.perf_buffer_poll()
except KeyboardInterrupt:
    print("\nProgram interrupted. Exiting gracefully...")
