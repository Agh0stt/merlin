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

KFL_SRCS = kernel/kernel.fl kernel/kstd.fl kernel/kmalloc.fl kernel/vga.fl kernel/interrupts.fl kernel/pic.fl kernel/keyboard.fl kernel/pmm.fl kernel/vmm.fl kernel/fs.fl kernel/pci.fl kernel/shell.fl kernel/syscall.fl

kernel/kernel.s: $(KFL_SRCS) $(FALCONC)
	$(FALCONC) kernel/kernel.fl --freestanding -Ikernel -o kernel/kernel.s

kernel/kernel.o: kernel/kernel.s
	$(AS) kernel/kernel.s -o kernel/kernel.o

boot/boot.o: boot/boot.s
	$(AS) boot/boot.s -o boot/boot.o

boot/glue.o: boot/glue.s boot/idt_stubs.s
	$(AS) boot/glue.s -o boot/glue.o

boot/paging.o: boot/paging.s
	$(AS) boot/paging.s -o boot/paging.o

boot/tasking.o: boot/tasking.s
	$(AS) boot/tasking.s -o boot/tasking.o

boot/ata.o: boot/ata.s
	$(AS) boot/ata.s -o boot/ata.o

# usermode_test.bin must exist before usermode.s is assembled, since
# usermode.s pulls it in with .incbin.
boot/usermode_test.o: boot/usermode_test.s
	$(AS) boot/usermode_test.s -o boot/usermode_test.o

boot/usermode_test.bin: boot/usermode_test.o
	objcopy -O binary boot/usermode_test.o boot/usermode_test.bin

boot/usermode.o: boot/usermode.s boot/usermode_test.bin
	$(AS) boot/usermode.s -o boot/usermode.o

BOOT_OBJS = boot/boot.o boot/glue.o boot/paging.o boot/tasking.o boot/ata.o boot/usermode.o

kestrel.elf: $(BOOT_OBJS) kernel/kernel.o boot/link.ld
	$(LD) -T boot/link.ld $(BOOT_OBJS) kernel/kernel.o -o kestrel.elf

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
	rm -f boot/*.o boot/usermode_test.bin kernel/*.o kernel/kernel.s kestrel.elf merlinos.iso
	rm -rf iso
