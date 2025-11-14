#!/usr/bin/env python3
from bcc import BPF
from ctypes import c_uint
import time, os, sys

def detect_interface():
    if len(sys.argv) > 1:
        return sys.argv[1]
    return "enp4s0"

iface = detect_interface()
print(f"[+] Using interface: {iface}")

program = r"""
#include <uapi/linux/bpf.h>
#include <uapi/linux/if_ether.h>
#include <uapi/linux/ip.h>
#include <uapi/linux/udp.h>
#include <uapi/linux/tcp.h>
#include <linux/icmp.h>   // <-- FIXED HEADER
#include <linux/in.h>

BPF_HASH(counter, u32, u64);

static void incr(u32 key)
{
    u64 *val = counter.lookup(&key);
    if (val)
        (*val)++;
    else {
        u64 init = 1;
        counter.update(&key, &init);
    }
}

int xdp_count(struct xdp_md *ctx)
{
    void *data     = (void *)(long)ctx->data;
    void *data_end = (void *)(long)ctx->data_end;

    incr(0); // total packets

    struct ethhdr *eth = data;
    if ((void*)eth + sizeof(*eth) > data_end)
        return XDP_PASS;

    if (eth->h_proto == __constant_htons(ETH_P_ARP))
        incr(1);

    if (eth->h_proto == __constant_htons(ETH_P_IP))
        incr(2);

    if (eth->h_proto == __constant_htons(ETH_P_IPV6))
        incr(3);

    if (eth->h_proto != __constant_htons(ETH_P_IP))
        return XDP_PASS;

    struct iphdr *ip = data + sizeof(*eth);
    if ((void*)ip + sizeof(*ip) > data_end)
        return XDP_PASS;

    if (ip->protocol == IPPROTO_TCP)
        incr(10);

    if (ip->protocol == IPPROTO_UDP)
        incr(11);

    if (ip->protocol == IPPROTO_ICMP)
        incr(12);

    return XDP_PASS;
}
"""

b = BPF(text=program)
fn = b.load_func("xdp_count", BPF.XDP)

from bcc import BPF as _BPF
print(f"[+] Attaching XDP to {iface} (SKB mode)")
b.attach_xdp(iface, fn, _BPF.XDP_FLAGS_SKB_MODE)
print("[+] XDP traffic monitor running.\n")

NAMES = {
    0: "Total packets",
    1: "ARP",
    2: "IPv4",
    3: "IPv6",
    10: "TCP",
    11: "UDP",
    12: "ICMP",
}

try:
    while True:
        time.sleep(1)
        os.system("clear")
        print("=== XDP Traffic Counters ===\n")

        table = b.get_table("counter")
        for key, label in NAMES.items():
            k = c_uint(key)
            try:
                v = table[k].value
            except KeyError:
                v = 0
            print(f"{label:<15}: {v}")

except KeyboardInterrupt:
    pass

print("[+] Detaching...")
b.remove_xdp(iface, _BPF.XDP_FLAGS_SKB_MODE)
print("[+] Done.")
