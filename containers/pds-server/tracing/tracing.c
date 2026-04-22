#include <stdio.h>
#include <bpf/libbpf.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include "tracing.skel.h"

struct data_t
{
	__u64 time;
	__u32 snd_addr;
	__u32 rcv_addr;
	__u16 snd_port;
	__u16 rcv_port;
	__u32 snd_cwnd;
	__u32 snd_una;
};

static int handle_event(void *ctx, void *data, size_t data_sz) {
    const struct data_t *d = data;
    printf("%llu,%u,%u,%u,%u,%u,%u\n",
        d->time, d->snd_cwnd, d->snd_una, d->snd_addr, d->rcv_addr, d->snd_port, d->rcv_port);
    return 0;
}

int main() {
    struct tracing_bpf *skel = tracing_bpf__open_and_load();
    if (!skel) return 1;

    if (tracing_bpf__attach(skel)) goto cleanup;

	printf("time,cwnd,una,saddr,daddr,sport,dport\n");
    struct ring_buffer *rb = ring_buffer__new(bpf_map__fd(skel->maps.rb), handle_event, NULL, NULL);
    if (!rb) goto cleanup;

    while (ring_buffer__poll(rb, 100) >= 0);

cleanup:
    tracing_bpf__destroy(skel);
    return 0;
}
