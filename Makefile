CLANG = clang
CFLAGS = -g -O2 -Wall -Wextra
TARGET = simplelbdsr
SEC = xdp

BPF_TARGET = ${TARGET:=.bpf}
BPF_C = ${BPF_TARGET:=.c}
BPF_OBJ = ${BPF_C:.c=.o}

clean:
	bpftool net detach xdpgeneric dev eth0
	rm -f /sys/fs/bpf/$(SEC)
	rm -f $(BPF_OBJ)
	rm -f vmlinux.h

vmlinux.h:
	bpftool btf dump file /sys/kernel/btf/vmlinux format c > $@

$(BPF_OBJ): %.bpf.c vmlinux.h
	$(CLANG) $(CFLAGS) -target bpf -c $<

all: $(BPF_OBJ)
	bpftool net detach xdpgeneric dev eth0
	rm -f /sys/fs/bpf/$(SEC)
	bpftool prog load $(BPF_OBJ) /sys/fs/bpf/$(SEC)
	bpftool net attach xdpgeneric pinned /sys/fs/bpf/$(SEC) dev eth0 

.PHONY: all clean

.DELETE_ON_ERROR:
.SECONDARY:
