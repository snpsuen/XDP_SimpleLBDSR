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


clean:
	rm -f $(PROGS)
	rm -f vmlinux.h *.bpf.o *.skel.h
,,,

xdp: $(BPF_OBJ)
	bpftool net detach xdpgeneric dev eth0
	rm -f /sys/fs/bpf/$(TARGET)
	bpftool prog load $(BPF_OBJ) /sys/fs/bpf/$(TARGET)
	bpftool net attach xdpgeneric pinned /sys/fs/bpf/$(TARGET) dev eth0 

$(BPF_OBJ): %.o: %.c
	clang -S \
	    -target bpf \
	    -D __BPF_TRACING__ \
	    -Ilibbpf/src \
	    -Wall \
	    -Wno-unused-value \
	    -Wno-pointer-sign \
	    -Wno-compare-distinct-pointer-types \
	    -Werror \
	    -O2 -emit-llvm -c -o ${@:.o=.ll} $<
	llc -march=bpf -filetype=obj -o $@ ${@:.o=.ll}

clean:
	bpftool net detach xdpgeneric dev eth0
	rm -f /sys/fs/bpf/$(TARGET)
	rm $(BPF_OBJ)
	rm ${BPF_OBJ:.o=.ll}
