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
