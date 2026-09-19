# glue.s — GDT/IDT setup and interrupt dispatch for Kestrel
#
# Everything here is asm because it has to be: table formats with
# bit-packed fields, lgdt/lidt, segment reloads, and the raw interrupt
# entry/exit sequence (pusha/iret). The actual *handling* of an
# exception or IRQ is Falcon code -- isr_handler(int_no, err_code) and
# irq_handler(int_no) below are just called by symbol name, the same
# way boot.s calls main().

    .section .data
    .align 8
gdt_start:
    .quad 0                     # 0x00 null descriptor
    .word 0xFFFF, 0x0000        # 0x08 code: limit=0xFFFFF base=0
    .byte 0x00, 0x9A, 0xCF, 0x00
    .word 0xFFFF, 0x0000        # 0x10 data: limit=0xFFFFF base=0
    .byte 0x00, 0x92, 0xCF, 0x00
gdt_end:

gdt_ptr:
    .word gdt_end - gdt_start - 1
    .long gdt_start

isr_table:
    .long isr0,  isr1,  isr2,  isr3,  isr4,  isr5,  isr6,  isr7
    .long isr8,  isr9,  isr10, isr11, isr12, isr13, isr14, isr15
    .long isr16, isr17, isr18, isr19, isr20, isr21, isr22, isr23
    .long isr24, isr25, isr26, isr27, isr28, isr29, isr30, isr31
    .long irq0,  irq1,  irq2,  irq3,  irq4,  irq5,  irq6,  irq7
    .long irq8,  irq9,  irq10, irq11, irq12, irq13, irq14, irq15

    .section .bss
    .align 8
idt_start:
    .skip 256 * 8
idt_ptr:
    .skip 6

    .section .text

# ---- GDT ----------------------------------------------------------
.globl gdt_init
gdt_init:
    lgdt gdt_ptr
    movl  $0x10, %eax
    movw  %ax, %ds
    movw  %ax, %es
    movw  %ax, %fs
    movw  %ax, %gs
    movw  %ax, %ss
    ljmp  $0x08, $1f
1:
    ret

# ---- IDT ------------------------------------------------------------
# Build all 48 gates we know about from isr_table; the other 208
# vectors stay zeroed (.bss) -- firing one of those before we add more
# handlers is a bug we *want* to show up as a triple fault.
.globl idt_init
idt_init:
    pushl %ebx
    xorl  %ecx, %ecx
1:
    cmpl  $48, %ecx
    jge   2f
    movl  isr_table(,%ecx,4), %eax
    movl  %ecx, %ebx
    shll  $3, %ebx
    addl  $idt_start, %ebx
    movw  %ax, (%ebx)          # base 0:15
    movw  $0x08, 2(%ebx)       # selector -> kernel code segment
    movb  $0x00, 4(%ebx)       # always zero
    movb  $0x8E, 5(%ebx)       # present, ring0, 32-bit interrupt gate
    shrl  $16, %eax
    movw  %ax, 6(%ebx)         # base 16:31
    incl  %ecx
    jmp   1b
2:
    movw  $2047, idt_ptr
    movl  $idt_start, idt_ptr+2
    lidt  idt_ptr
    popl  %ebx
    ret

# ---- common dispatch ------------------------------------------------
# Stack on entry (stub already pushed int_no then err_code -- or a
# dummy 0 -- before jumping here): [esp]=int_no [esp+4]=err_code
# then the CPU's own interrupt frame (eip/cs/eflags/...).
isr_common_stub:
    pusha
    movw  %ds, %ax
    pushl %eax
    movw  $0x10, %ax
    movw  %ax, %ds
    movw  %ax, %es
    movw  %ax, %fs
    movw  %ax, %gs

    movl  %cr2, %eax           # only meaningful for #PF (vector 14), but
    movl  %eax, _gv_g_cr2      # cheap enough to always capture

    movl  36(%esp), %eax       # int_no
    movl  40(%esp), %ebx       # err_code
    pushl %ebx
    pushl %eax
    call  isr_handler
    addl  $8, %esp

    popl  %eax
    movw  %ax, %ds
    movw  %ax, %es
    movw  %ax, %fs
    movw  %ax, %gs
    popa
    addl  $8, %esp             # drop int_no/err_code the stub pushed
    iret

irq_common_stub:
    pusha
    movw  %ds, %ax
    pushl %eax
    movw  $0x10, %ax
    movw  %ax, %ds
    movw  %ax, %es
    movw  %ax, %fs
    movw  %ax, %gs

    movl  36(%esp), %eax       # int_no (32-47)
    pushl %eax
    call  irq_handler
    addl  $4, %esp

    popl  %eax
    movw  %ax, %ds
    movw  %ax, %es
    movw  %ax, %fs
    movw  %ax, %gs
    popa
    addl  $8, %esp
    iret

.include "boot/idt_stubs.s"
