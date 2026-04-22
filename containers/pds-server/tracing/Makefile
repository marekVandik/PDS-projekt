# Makefile
# Author: Marek Vandik
# 17. 4. 2026


default: build

vmlinux.h:
	bpftool btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h

tracing.bpf.o: tracing.bpf.c vmlinux.h
	clang -g -O2 -I. -target bpf -D__TARGET_ARCH_x86 -c tracing.bpf.c -o tracing.bpf.o

tracing.skel.h: tracing.bpf.o
	bpftool gen skeleton tracing.bpf.o > tracing.skel.h

tracing: tracing.c tracing.skel.h vmlinux.h
	gcc -g -O2 tracing.c -lbpf -lelf -lz -o tracing

build: tracing tracing.bpf.o

clean:
	rm tracing tracing.bpf.o tracing.skel.h vmlinux.h
