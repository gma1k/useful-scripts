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

    // Check if it's a read or write operation
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
