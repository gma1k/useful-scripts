#!/usr/bin/env python3

from bcc import BPF
from time import sleep
import argparse

bpf_text = """
#include <uapi/linux/ptrace.h>
#include <linux/sched.h>

struct resource_usage {
    u32 pid;
    char comm[TASK_COMM_LEN];
    u64 cpu_usage;
    u64 mem_usage;
    u64 io_ops;
};

BPF_HASH(service_resources, u32, struct resource_usage);

int do_perf_event(struct pt_regs *ctx) {
    u32 pid = bpf_get_current_pid_tgid() >> 32;
    
    struct resource_usage *usage = service_resources.lookup(&pid);
    if (!usage) {
        struct resource_usage new_usage = {};
        new_usage.pid = pid;
        bpf_get_current_comm(&new_usage.comm, sizeof(new_usage.comm));
        service_resources.update(&pid, &new_usage);
        usage = service_resources.lookup(&pid);
        if (!usage) return 0;
    }
    
    usage->cpu_usage += 1;
    
    return 0;
}
"""

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--interval", type=int, default=5,
                      help="Monitoring interval in seconds")
    args = parser.parse_args()

    b = BPF(text=bpf_text)
    b.attach_kprobe(event="finish_task_switch", fn_name="do_perf_event")

    try:
        while True:
            sleep(args.interval)
            print("\nService Resource Usage:")
            print("%-6s %-16s %-10s %-10s %-10s" % 
                 ("PID", "COMM", "CPU", "MEM", "IO"))
            
            for k, v in b["service_resources"].items():
                print("%-6d %-16s %-10d %-10d %-10d" % 
                     (v.pid, v.comm.decode(), v.cpu_usage, v.mem_usage, v.io_ops))
            
            b["service_resources"].clear()
    except KeyboardInterrupt:
        pass

if __name__ == "__main__":
    main()
