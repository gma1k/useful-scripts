#!/usr/bin/env python3

from bcc import BPF
import ctypes
import socket
import sys

class DnsEvent(ctypes.Structure):
    _fields_ = [
        ("ts_ns",   ctypes.c_uint64),
        ("src_ip",  ctypes.c_uint32),
        ("dst_ip",  ctypes.c_uint32),
        ("src_port", ctypes.c_uint16),
        ("dst_port", ctypes.c_uint16),
        ("id",      ctypes.c_uint16),
        ("flags",   ctypes.c_uint16),
    ]

def ip_to_str(ip):
    return socket.inet_ntoa(socket.ntohl(ip).to_bytes(4, "big"))

program = r"""
#include <uapi/linux/bpf.h>
#include <uapi/linux/if_ether.h>
#include <uapi/linux/ip.h>
#include <uapi/linux/udp.h>

struct dns_event {
    __u64 ts_ns;
    __u32 src_ip;
    __u32 dst_ip;
    __u16 src_port;
    __u16 dst_port;
    __u16 id;
    __u16 flags;
};

BPF_PERF_OUTPUT(events);

static __always_inline int parse_dns(struct xdp_md *ctx,
                                     void *data, void *data_end,
                                     struct iphdr *ip, struct udphdr *udp)
{
    unsigned char *dns = (unsigned char *)udp + sizeof(*udp);

    if (dns + 12 > (unsigned char *)data_end)
        return 0;

    struct dns_event ev = {};
    ev.ts_ns   = bpf_ktime_get_ns();
    ev.src_ip  = ip->saddr;
    ev.dst_ip  = ip->daddr;
    ev.src_port = bpf_ntohs(udp->source);
    ev.dst_port = bpf_ntohs(udp->dest);

    ev.id    = ((__u16)dns[0] << 8) | dns[1];
    ev.flags = ((__u16)dns[2] << 8) | dns[3];

    events.perf_submit(ctx, &ev, sizeof(ev));
    return 1;
}

int xdp_dns_tap(struct xdp_md *ctx)
{
    void *data     = (void *)(long)ctx->data;
    void *data_end = (void *)(long)ctx->data_end;

    struct ethhdr *eth = data;
    if ((void *)(eth + 1) > data_end)
        return XDP_PASS;

    if (eth->h_proto != __constant_htons(ETH_P_IP))
        return XDP_PASS;

    struct iphdr *ip = (void *)(eth + 1);
    if ((void *)(ip + 1) > data_end)
        return XDP_PASS;

    if (ip->protocol != 17)
        return XDP_PASS;

    struct udphdr *udp = (void *)(ip + 1);
    if ((void *)(udp + 1) > data_end)
        return XDP_PASS;

    if (udp->dest != __constant_htons(53) &&
        udp->source != __constant_htons(53))
        return XDP_PASS;

    parse_dns(ctx, data, data_end, ip, udp);
    return XDP_PASS;
}
"""

iface = sys.argv[1] if len(sys.argv) > 1 else "enp4s0"
print(f"[+] Using interface: {iface}")

b = BPF(text=program)
fn = b.load_func("xdp_dns_tap", BPF.XDP)

XDP_FLAGS_SKB_MODE = 1 << 1
XDP_FLAGS_DRV_MODE = 1 << 2

flags = XDP_FLAGS_DRV_MODE

try:
    print(f"[+] Attaching XDP (native/driver mode) to {iface}")
    b.attach_xdp(iface, fn, flags)
except Exception as e:
    print(f"[!] Failed to attach in native mode: {e}")
    print("[+] Falling back to XDP generic (SKB) mode")
    flags = XDP_FLAGS_SKB_MODE
    b.attach_xdp(iface, fn, flags)

first_ts = None
print("[+] DNS XDP tap running. Press Ctrl+C to stop.\n")

def handle_event(cpu, data, size):
    global first_ts
    ev = ctypes.cast(data, ctypes.POINTER(DnsEvent)).contents

    if first_ts is None:
        first_ts = ev.ts_ns

    t = (ev.ts_ns - first_ts) / 1e9

    print(f"[DNS] t={t:8.3f}s "
          f"{ip_to_str(ev.src_ip)}:{ev.src_port} -> "
          f"{ip_to_str(ev.dst_ip)}:{ev.dst_port} "
          f"id={ev.id} flags=0x{ev.flags:04x}")

b["events"].open_perf_buffer(handle_event)

try:
    while True:
        b.perf_buffer_poll()
except KeyboardInterrupt:
    pass

print("\n[+] Detaching XDP...")
b.remove_xdp(iface, flags)
print("[+] Done.")
