# Makefile — MerlinOS / Kestrel
#
# Requires: gcc, binutils (as/ld, 32-bit support), grub-mkrescue, xorriso,
# mtools, qemu-system-i386 (for `make run`).
#
#   sudo apt install build-essential grub-pc-bin grub-common xorriso mtools qemu-system-x86

FALCON_SRC = falcon/falconc.c
FALCONC    = falcon/falconc
AS         = as --32
LD         = ld -m elf_i386

.PHONY: all iso run clean falconc

all: kestrel.elf

falconc: $(FALCONC)

$(FALCONC): $(FALCON_SRC)
	gcc -O2 -w -o $(FALCONC) $(FALCON_SRC)

KFL_SRCS = kernel/kernel.fl kernel/kstd.fl kernel/vga.fl kernel/interrupts.fl kernel/pic.fl kernel/keyboard.fl

kernel/kernel.s: $(KFL_SRCS) $(FALCONC)
	$(FALCONC) kernel/kernel.fl --freestanding -Ikernel -o kernel/kernel.s

kernel/kernel.o: kernel/kernel.s
	$(AS) kernel/kernel.s -o kernel/kernel.o

boot/boot.o: boot/boot.s
	$(AS) boot/boot.s -o boot/boot.o

boot/glue.o: boot/glue.s boot/idt_stubs.s
	$(AS) boot/glue.s -o boot/glue.o

kestrel.elf: boot/boot.o boot/glue.o kernel/kernel.o boot/link.ld
	$(LD) -T boot/link.ld boot/boot.o boot/glue.o kernel/kernel.o -o kestrel.elf

iso: kestrel.elf
	mkdir -p iso/boot/grub
	cp kestrel.elf iso/boot/kestrel.elf
	cp boot/grub.cfg iso/boot/grub/grub.cfg
	grub-mkrescue -o merlinos.iso iso

run: iso
	qemu-system-i386 -cdrom merlinos.iso

run-direct: kestrel.elf
	qemu-system-i386 -kernel kestrel.elf

clean:
	rm -f boot/*.o kernel/*.o kernel/kernel.s kestrel.elf merlinos.iso
	rm -rf iso
