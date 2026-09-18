# boot.s — Multiboot header + entry point for MerlinOS / Kestrel
# Assembled with: as --32 boot.s -o boot.o
#
# GRUB loads this as a multiboot kernel. On entry:
#   eax = multiboot magic (0x2BADB002)
#   ebx = pointer to multiboot info struct
# We stash both where Falcon can read them, set up our own stack,
# then call into Falcon's main(). main() never returns in
# --freestanding mode (falconc emits an automatic cli/hlt loop at
# the end of it), so there is nothing to do after the call.

.set MAGIC,    0x1BADB002
.set ALIGN,    1<<0            # align loaded modules on page boundaries
.set MEMINFO,  1<<1            # provide memory map
.set FLAGS,    ALIGN | MEMINFO
.set CHECKSUM, -(MAGIC + FLAGS)

    .section .multiboot
    .align 4
    .long MAGIC
    .long FLAGS
    .long CHECKSUM

    .section .bss
    .align 16
stack_bottom:
    .skip 16384                # 16 KiB kernel stack
stack_top:

    .section .data
.globl mb_magic
mb_magic:
    .long 0
.globl mb_info
mb_info:
    .long 0

    .section .text
.globl _start
_start:
    cli
    movl $stack_top, %esp
    movl %esp, %ebp

    movl %eax, mb_magic         # stash for Falcon to __peek() if it ever needs them
    movl %ebx, mb_info

    call  main                  # never returns (freestanding main ends in hlt loop)

.hang:
    cli
    hlt
    jmp   .hang
