#!/usr/bin/env python3

from bcc import BPF
import ctypes
import os
import time
from collections import defaultdict

bpf_text = """
#include <uapi/linux/ptrace.h>
#include <linux/module.h>
#include <linux/sched.h>

enum scan_type {
    DRIVER_LOADED = 1,
    DRIVER_ERROR = 2,
};

struct driver_scan_result {
    char comm[TASK_COMM_LEN];
    char modname[MODULE_NAME_LEN];
    u32 pid;
    int error;
    enum scan_type type;
};

BPF_PERF_OUTPUT(scan_results);

int trace_module_load(struct pt_regs *ctx, struct module *mod) {
    struct driver_scan_result result = {};
    result.type = DRIVER_LOADED;
    result.pid = bpf_get_current_pid_tgid() >> 32;
    bpf_get_current_comm(&result.comm, sizeof(result.comm));
    
    if (mod) {
        bpf_probe_read_kernel_str(&result.modname, sizeof(result.modname), mod->name);
    }
    
    scan_results.perf_submit(ctx, &result, sizeof(result));
    return 0;
}

int trace_driver_error(struct pt_regs *ctx, int err) {
    if (err < 0) {
        struct driver_scan_result result = {};
        result.type = DRIVER_ERROR;
        result.pid = bpf_get_current_pid_tgid() >> 32;
        result.error = err;
        bpf_get_current_comm(&result.comm, sizeof(result.comm));
        scan_results.perf_submit(ctx, &result, sizeof(result));
    }
    return 0;
}
"""

def run_driver_scan(scan_duration=5):
    b = BPF(text=bpf_text,
            cflags=["-Wno-macro-redefined",
                    "-Wno-address-of-packed-member"])

    b.attach_kprobe(event="security_kernel_module_request", fn_name="trace_module_load")
    b.attach_kretprobe(event="__request_module", fn_name="trace_driver_error")

    driver_db = defaultdict(dict)
    scan_complete = False

    def print_scan_result(cpu, data, size):
        nonlocal scan_complete
        result = b["scan_results"].event(data)
        
        if result.type == 1:  # DRIVER_LOADED
            modname = result.modname.decode()
            driver_db[modname]['loaded'] = True
            driver_db[modname]['pid'] = result.pid
            print(f"[+] Driver loaded: {modname} (PID: {result.pid})")
            
        elif result.type == 2:  # DRIVER_ERROR
            driver = result.comm.decode()
            driver_db[driver]['errors'] = driver_db[driver].get('errors', 0) + 1
            print(f"[-] Driver error: {driver} (Code: {result.error})")

    print(f"[*] Scanning system drivers for {scan_duration} seconds...")
    b["scan_results"].open_perf_buffer(print_scan_result)

    os.system("lsmod > /dev/null 2>&1")

    start_time = time.time()
    
    while time.time() - start_time < scan_duration:
        b.perf_buffer_poll(timeout=500)  # 500ms timeout
        
    print("\n[***] Final Driver Scan Report [***]")
    print("="*60)
    print("{:<20} {:<10} {:<10} {:<15}".format("Driver", "Loaded", "Errors", "Loaded By"))
    print("-"*60)
    
    with open('/proc/modules', 'r') as f:
        for line in f:
            parts = line.split()
            modname = parts[0]
            if modname not in driver_db:
                driver_db[modname]['loaded'] = True
    
    for driver, info in sorted(driver_db.items()):
        print("{:<20} {:<10} {:<10} {:<15}".format(
            driver,
            "Yes" if info.get('loaded') else "No",
            info.get('errors', 0),
            str(info.get('pid', 'kernel'))
        ))
    print("="*60)

if __name__ == "__main__":
    run_driver_scan(scan_duration=5)
