from bcc import BPF

program = """
#include <uapi/linux/ptrace.h>
#include <net/sock.h>
#include <linux/tcp.h>
#include <linux/inet.h>

struct conn_event_t {
    u32 pid;
    u32 uid;
    u64 ts;
    u32 protocol;
    u32 family;
    u16 sport;
    u16 dport;
    char task[16];
};

BPF_PERF_OUTPUT(events);

int trace_tcp(struct pt_regs *ctx) {
    struct sock *sk = NULL;
    struct conn_event_t event = {};
    u16 family = 0, sport = 0, dport = 0;

    sk = (struct sock *)PT_REGS_PARM1(ctx);
    if (!sk)
        return 0;

    bpf_probe_read_kernel(&family, sizeof(family), &sk->__sk_common.skc_family);
    bpf_probe_read_kernel(&sport, sizeof(sport), &sk->__sk_common.skc_num);
    bpf_probe_read_kernel(&dport, sizeof(dport), &sk->__sk_common.skc_dport);

    event.pid = bpf_get_current_pid_tgid() >> 32;
    event.uid = bpf_get_current_uid_gid();
    event.ts = bpf_ktime_get_ns();
    bpf_get_current_comm(&event.task, sizeof(event.task));
    event.protocol = 6;  // TCP
    event.family = family;
    event.sport = sport;
    event.dport = ntohs(dport);

    events.perf_submit(ctx, &event, sizeof(event));
    return 0;
}
"""

b = BPF(text=program)
b.attach_kprobe(event="tcp_connect", fn_name="trace_tcp")

def print_event(cpu, data, size):
    event = b["events"].event(data)
    print(f"{event.task.decode()} pid={event.pid} uid={event.uid} sport={event.sport} dport={event.dport} family={event.family}")

b["events"].open_perf_buffer(print_event)
print("Tracing... Press Ctrl+C to exit.")
while True:
    try:
        b.perf_buffer_poll()
    except KeyboardInterrupt:
        exit()
