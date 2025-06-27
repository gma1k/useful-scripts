#!/usr/bin/env python3

from bcc import BPF
from time import sleep
import ctypes as ct
import os

bpf_program = """
#include <uapi/linux/ptrace.h>
#include <linux/blkdev.h>

struct data_t {
    u32 pid;
    u64 bytes;
    char comm[TASK_COMM_LEN];
};

BPF_HASH(read_bytes, u32, u64);
BPF_HASH(write_bytes, u32, u64);

TRACEPOINT_PROBE(block, block_rq_issue) {
    u32 pid = bpf_get_current_pid_tgid() >> 32;
    if (pid == 0)
        return 0;

    u64 bytes = args->bytes;

    if (args->rwbs[0] == 'R') {
        u64 *val, zero = 0;
        val = read_bytes.lookup_or_init(&pid, &zero);
        (*val) += bytes;
    } else if (args->rwbs[0] == 'W') {
        u64 *val, zero = 0;
        val = write_bytes.lookup_or_init(&pid, &zero);
        (*val) += bytes;
    }

    return 0;
}
"""

print("Loading eBPF program...")
b = BPF(text=bpf_program)

print("Monitoring disk I/O per process... Press Ctrl+C to stop.")
try:
    while True:
        sleep(5)
        print("\n%-6s %-16s %-10s %-10s" % ("PID", "COMM", "READ (KB)", "WRITE (KB)"))

        read_table = b.get_table("read_bytes")
        write_table = b.get_table("write_bytes")

        read_pids = {k.value for k in read_table.keys()}
        write_pids = {k.value for k in write_table.keys()}
        all_pids = read_pids | write_pids

        for pid in all_pids:
            try:
                with open(f"/proc/{pid}/comm") as f:
                    comm = f.read().strip()
            except:
                comm = "unknown"

            read_kb = read_table[ct.c_uint(pid)].value / 1024 if ct.c_uint(pid) in read_table else 0
            write_kb = write_table[ct.c_uint(pid)].value / 1024 if ct.c_uint(pid) in write_table else 0

            print("%-6d %-16s %-10.0f %-10.0f" % (pid, comm, read_kb, write_kb))

        read_table.clear()
        write_table.clear()

except KeyboardInterrupt:
    print("\nExiting.")
