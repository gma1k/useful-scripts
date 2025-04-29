#!/usr/bin/env python3

from bcc import BPF
import ctypes
import time
from collections import defaultdict

bpf_text = """
#include <uapi/linux/ptrace.h>
#include <linux/module.h>
#include <linux/fs.h>

struct driver_event {
    char comm[TASK_COMM_LEN];  // Process name
    char modname[MODULE_NAME_LEN]; // Module name
    u32 pid;
    int error;
    u32 irq;
};

BPF_PERF_OUTPUT(driver_events);

int trace_module_load(struct pt_regs *ctx, struct module *mod) {
    struct driver_event event = {};
    event.pid = bpf_get_current_pid_tgid() >> 32;
    bpf_get_current_comm(&event.comm, sizeof(event.comm));
    
    if (mod) {
        bpf_probe_read_kernel_str(&event.modname, sizeof(event.modname), mod->name);
    }
    
    driver_events.perf_submit(ctx, &event, sizeof(event));
    return 0;
}

int trace_io_error(struct pt_regs *ctx, int err) {
    if (err < 0) {  // Only log actual errors
        struct driver_event event = {};
        event.pid = bpf_get_current_pid_tgid() >> 32;
        event.error = err;
        bpf_get_current_comm(&event.comm, sizeof(event.comm));
        driver_events.perf_submit(ctx, &event, sizeof(event));
    }
    return 0;
}

int trace_irq_entry(struct pt_regs *ctx, unsigned int irq) {
    struct driver_event event = {};
    event.pid = bpf_get_current_pid_tgid() >> 32;
    event.irq = irq;
    bpf_get_current_comm(&event.comm, sizeof(event.comm));
    driver_events.perf_submit(ctx, &event, sizeof(event));
    return 0;
}
"""

b = BPF(text=bpf_text,
        cflags=["-Wno-macro-redefined",
                "-Wno-address-of-packed-member"])

b.attach_kprobe(event="__request_module", fn_name="trace_module_load")
b.attach_kprobe(event="blk_status_to_errno", fn_name="trace_io_error")
b.attach_kprobe(event="handle_irq_event_percpu", fn_name="trace_irq_entry")

print("{:<16} {:<8} {:<24} {:<12} {}".format(
    "Process", "PID", "Module/IRQ", "Error", "Details"
))

def print_event(cpu, data, size):
    event = b["driver_events"].event(data)
    details = ""
    
    if event.error != 0:
        details = f"I/O Error: {event.error}"
    elif event.irq != 0:
        details = f"IRQ Handler: {event.irq}"
    elif event.modname[0]:
        details = f"Module: {event.modname.decode()}"
    else:
        details = "Kernel Activity"
    
    print("{:<16} {:<8} {:<24} {:<12} {}".format(
        event.comm.decode(),
        event.pid,
        event.modname.decode() if event.modname[0] else f"IRQ-{event.irq}",
        event.error if event.error != 0 else "OK",
        details
    ))

b["driver_events"].open_perf_buffer(print_event)

print("[*] Monitoring driver activities. Ctrl-C to exit.")
while True:
    try:
        b.perf_buffer_poll()
    except KeyboardInterrupt:
        exit()
