#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_core_read.h>
#include <bpf/bpf_tracing.h>

struct data_t
{
	u64 time;
	u32 snd_addr;
	u32 rcv_addr;
	u16 snd_port;
	u16 rcv_port;
	u32 snd_cwnd;
	u32 snd_una;
};

struct buffer
{
	__uint(type, BPF_MAP_TYPE_RINGBUF);
	__uint(max_entries, 1024 * 1024);
} rb SEC(".maps");

const char LICENSE[] SEC("license") = "Dual BSD/GPL";

SEC("kprobe/tcp_rcv_established")
int kprobe_tcp_rcv_established(struct pt_regs *ctx)
{
	struct sock *sk = (struct sock *)PT_REGS_PARM1(ctx);
	struct tcp_sock *t_sk = (struct tcp_sock *)sk;
	if (t_sk == NULL)
	{
		return 0;
	}

	struct data_t *d = bpf_ringbuf_reserve(&rb, sizeof(struct data_t), 0);
	if (d == NULL)
	{
		return 0;
	}

	d->time = bpf_ktime_get_ns();
	d->snd_addr = BPF_CORE_READ(sk, __sk_common.skc_rcv_saddr);
	d->rcv_addr = BPF_CORE_READ(sk, __sk_common.skc_daddr);
	d->snd_port = BPF_CORE_READ(sk, __sk_common.skc_num);
	d->rcv_port = BPF_CORE_READ(sk, __sk_common.skc_dport);
	d->snd_cwnd = BPF_CORE_READ(t_sk, snd_cwnd);
	d->snd_una = BPF_CORE_READ(t_sk, snd_una);

	bpf_ringbuf_submit(d, 0);

	return 0;
}
