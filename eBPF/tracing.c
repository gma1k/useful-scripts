// SPDX-License-Identifier: GPL-2.0

#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>
#include <bpf/bpf_core_read.h>

#define MAX_STRING_LEN 64
#define MAX_EVENTS 1024

#ifndef BPF_MAP_TYPE_PERF_EVENT_ARRAY
#define BPF_MAP_TYPE_PERF_EVENT_ARRAY 4
#endif
#ifndef BPF_MAP_TYPE_HASH
#define BPF_MAP_TYPE_HASH 1
#endif
#ifndef BPF_ANY
#define BPF_ANY 0
#endif
#ifndef BPF_F_CURRENT_CPU
#define BPF_F_CURRENT_CPU 0xffffffffULL
#endif

enum event_type {
	EVENT_DNS,
	EVENT_CONNECT,
	EVENT_TCP_SEND,
	EVENT_TCP_RECV,
	EVENT_WRITE,
	EVENT_FSYNC,
	EVENT_SCHED_SWITCH,
};

struct event {
	u64 timestamp;
	u32 pid;
	u32 type;
	u64 latency_ns;
	s32 error;
	char target[MAX_STRING_LEN];
	char details[MAX_STRING_LEN];
};

struct {
	__uint(type, BPF_MAP_TYPE_PERF_EVENT_ARRAY);
	__uint(key_size, sizeof(u32));
	__uint(value_size, sizeof(u32));
} events SEC(".maps");

struct {
	__uint(type, BPF_MAP_TYPE_HASH);
	__uint(max_entries, 1024);
	__type(key, u64);
	__type(value, u64);
} start_times SEC(".maps");

static inline u64 get_key(u32 pid, u32 tid) {
	return ((u64)pid << 32) | tid;
}

static inline u64 calc_latency(u64 start) {
	u64 now = bpf_ktime_get_ns();
	return now > start ? now - start : 0;
}

static inline void format_ip_port(u32 ip, u16 port, char *buf) {
	u8 a = (ip >> 24) & 0xFF;
	u8 b = (ip >> 16) & 0xFF;
	u8 c = (ip >> 8) & 0xFF;
	u8 d = ip & 0xFF;
	u16 p = port;
	
	buf[0] = '0' + (a / 100) % 10;
	buf[1] = '0' + (a / 10) % 10;
	buf[2] = '0' + a % 10;
	buf[3] = '.';
	buf[4] = '0' + (b / 100) % 10;
	buf[5] = '0' + (b / 10) % 10;
	buf[6] = '0' + b % 10;
	buf[7] = '.';
	buf[8] = '0' + (c / 100) % 10;
	buf[9] = '0' + (c / 10) % 10;
	buf[10] = '0' + c % 10;
	buf[11] = '.';
	buf[12] = '0' + (d / 100) % 10;
	buf[13] = '0' + (d / 10) % 10;
	buf[14] = '0' + d % 10;
	buf[15] = ':';
	buf[16] = '0' + (p / 10000) % 10;
	buf[17] = '0' + (p / 1000) % 10;
	buf[18] = '0' + (p / 100) % 10;
	buf[19] = '0' + (p / 10) % 10;
	buf[20] = '0' + p % 10;
	buf[21] = '\0';
}

SEC("kprobe/tcp_v4_connect")
int kprobe_tcp_connect(struct pt_regs *ctx) {
	u32 pid = bpf_get_current_pid_tgid() >> 32;
	u32 tid = (u32)bpf_get_current_pid_tgid();
	u64 key = get_key(pid, tid);
	u64 ts = bpf_ktime_get_ns();
	
	bpf_map_update_elem(&start_times, &key, &ts, BPF_ANY);
	return 0;
}

SEC("kretprobe/tcp_v4_connect")
int kretprobe_tcp_connect(struct pt_regs *ctx) {
	u32 pid = bpf_get_current_pid_tgid() >> 32;
	u32 tid = (u32)bpf_get_current_pid_tgid();
	u64 key = get_key(pid, tid);
	u64 *start_ts = bpf_map_lookup_elem(&start_times, &key);
	
	if (!start_ts) {
		return 0;
	}
	
	struct event e = {};
	e.timestamp = bpf_ktime_get_ns();
	e.pid = pid;
	e.type = EVENT_CONNECT;
	e.latency_ns = calc_latency(*start_ts);
	e.error = PT_REGS_RC(ctx);
	
	struct sockaddr_in addr;
	void *uaddr = (void *)PT_REGS_PARM2(ctx);
	if (uaddr) {
		bpf_probe_read_user(&addr, sizeof(addr), uaddr);
		if (addr.sin_family == 2) { // AF_INET
			u16 port = __builtin_bswap16(addr.sin_port);
			u32 ip_be;
			bpf_probe_read_user(&ip_be, sizeof(ip_be), &addr.sin_addr.s_addr);
			u32 ip = __builtin_bswap32(ip_be);
			format_ip_port(ip, port, e.target);
		} else {
			e.target[0] = '\0';
		}
	} else {
		e.target[0] = '\0';
	}
	
	bpf_perf_event_output(ctx, &events, BPF_F_CURRENT_CPU, &e, sizeof(e));
	bpf_map_delete_elem(&start_times, &key);
	return 0;
}

SEC("kprobe/tcp_sendmsg")
int kprobe_tcp_sendmsg(struct pt_regs *ctx) {
	u32 pid = bpf_get_current_pid_tgid() >> 32;
	u32 tid = (u32)bpf_get_current_pid_tgid();
	u64 key = get_key(pid, tid);
	u64 ts = bpf_ktime_get_ns();
	
	bpf_map_update_elem(&start_times, &key, &ts, BPF_ANY);
	return 0;
}

SEC("kretprobe/tcp_sendmsg")
int kretprobe_tcp_sendmsg(struct pt_regs *ctx) {
	u32 pid = bpf_get_current_pid_tgid() >> 32;
	u32 tid = (u32)bpf_get_current_pid_tgid();
	u64 key = get_key(pid, tid);
	u64 *start_ts = bpf_map_lookup_elem(&start_times, &key);
	
	if (!start_ts) {
		return 0;
	}
	
	struct event e = {};
	e.timestamp = bpf_ktime_get_ns();
	e.pid = pid;
	e.type = EVENT_TCP_SEND;
	e.latency_ns = calc_latency(*start_ts);
	e.error = PT_REGS_RC(ctx);
	e.target[0] = '\0';
	
	bpf_perf_event_output(ctx, &events, BPF_F_CURRENT_CPU, &e, sizeof(e));
	bpf_map_delete_elem(&start_times, &key);
	return 0;
}

SEC("kprobe/tcp_recvmsg")
int kprobe_tcp_recvmsg(struct pt_regs *ctx) {
	u32 pid = bpf_get_current_pid_tgid() >> 32;
	u32 tid = (u32)bpf_get_current_pid_tgid();
	u64 key = get_key(pid, tid);
	u64 ts = bpf_ktime_get_ns();
	
	bpf_map_update_elem(&start_times, &key, &ts, BPF_ANY);
	return 0;
}

SEC("kretprobe/tcp_recvmsg")
int kretprobe_tcp_recvmsg(struct pt_regs *ctx) {
	u32 pid = bpf_get_current_pid_tgid() >> 32;
	u32 tid = (u32)bpf_get_current_pid_tgid();
	u64 key = get_key(pid, tid);
	u64 *start_ts = bpf_map_lookup_elem(&start_times, &key);
	
	if (!start_ts) {
		return 0;
	}
	
	struct event e = {};
	e.timestamp = bpf_ktime_get_ns();
	e.pid = pid;
	e.type = EVENT_TCP_RECV;
	e.latency_ns = calc_latency(*start_ts);
	e.error = PT_REGS_RC(ctx);
	e.target[0] = '\0';
	
	bpf_perf_event_output(ctx, &events, BPF_F_CURRENT_CPU, &e, sizeof(e));
	bpf_map_delete_elem(&start_times, &key);
	return 0;
}

SEC("kprobe/vfs_write")
int kprobe_vfs_write(struct pt_regs *ctx) {
	u32 pid = bpf_get_current_pid_tgid() >> 32;
	u32 tid = (u32)bpf_get_current_pid_tgid();
	u64 key = get_key(pid, tid);
	u64 ts = bpf_ktime_get_ns();
	
	bpf_map_update_elem(&start_times, &key, &ts, BPF_ANY);
	return 0;
}

SEC("kretprobe/vfs_write")
int kretprobe_vfs_write(struct pt_regs *ctx) {
	u32 pid = bpf_get_current_pid_tgid() >> 32;
	u32 tid = (u32)bpf_get_current_pid_tgid();
	u64 key = get_key(pid, tid);
	u64 *start_ts = bpf_map_lookup_elem(&start_times, &key);
	
	if (!start_ts) {
		return 0;
	}
	
	u64 latency = calc_latency(*start_ts);
	if (latency < 1000000) {
		bpf_map_delete_elem(&start_times, &key);
		return 0;
	}
	
	struct event e = {};
	e.timestamp = bpf_ktime_get_ns();
	e.pid = pid;
	e.type = EVENT_WRITE;
	e.latency_ns = latency;
	e.error = PT_REGS_RC(ctx);
	
	e.target[0] = '?';
	e.target[1] = '\0';
	
	bpf_perf_event_output(ctx, &events, BPF_F_CURRENT_CPU, &e, sizeof(e));
	bpf_map_delete_elem(&start_times, &key);
	return 0;
}

SEC("kprobe/vfs_fsync")
int kprobe_vfs_fsync(struct pt_regs *ctx) {
	u32 pid = bpf_get_current_pid_tgid() >> 32;
	u32 tid = (u32)bpf_get_current_pid_tgid();
	u64 key = get_key(pid, tid);
	u64 ts = bpf_ktime_get_ns();
	
	bpf_map_update_elem(&start_times, &key, &ts, BPF_ANY);
	return 0;
}

SEC("kretprobe/vfs_fsync")
int kretprobe_vfs_fsync(struct pt_regs *ctx) {
	u32 pid = bpf_get_current_pid_tgid() >> 32;
	u32 tid = (u32)bpf_get_current_pid_tgid();
	u64 key = get_key(pid, tid);
	u64 *start_ts = bpf_map_lookup_elem(&start_times, &key);
	
	if (!start_ts) {
		return 0;
	}
	
	u64 latency = calc_latency(*start_ts);
	if (latency < 1000000) {
		bpf_map_delete_elem(&start_times, &key);
		return 0;
	}
	
	struct event e = {};
	e.timestamp = bpf_ktime_get_ns();
	e.pid = pid;
	e.type = EVENT_FSYNC;
	e.latency_ns = latency;
	e.error = PT_REGS_RC(ctx);
	e.target[0] = '\0';
	
	bpf_perf_event_output(ctx, &events, BPF_F_CURRENT_CPU, &e, sizeof(e));
	bpf_map_delete_elem(&start_times, &key);
	return 0;
}

char LICENSE[] SEC("license") = "GPL";
