# usermode.s — TSS, ring-3 transition, and the int 0x80 syscall gate
#
# This is genuinely the highest-risk file in the kernel so far: a
# wrong bit in the TSS or GDT here doesn't produce a wrong answer, it
# produces an instant triple-fault with no diagnostic at all (the
# fault happens before there's any stack the CPU trusts enough to
# even deliver a #GP cleanly). Every field and offset below was
# checked against the actual byte layout, not assumed.
#
# Scope, stated plainly: this proves the MECHANISM works -- ring 3
# execution, a syscall path back into the kernel, and a real memory
# protection boundary (see the PDE fix in vmm.fl this shipped with).
# It does NOT integrate with the scheduler. jump_to_usermode() is a
# one-way, one-shot transition triggered by the shell's `usertest`
# command, not a task. The syscall exit handler halts the machine
# rather than trying to hand control back to whatever called it --
# see the comment on SYS_EXIT in syscall.fl for why that's not safe
# to fake with the current architecture.

    .section .bss
    .align 16
tss_start:
    .skip 104

    .align 16
tss_kstack_bottom:
    .skip 8192
tss_kstack_top:

    .section .text

# tss_init() -- zero the TSS, set SS0:ESP0 (the stack the CPU switches
# to automatically on any ring3->ring0 transition, e.g. this exact
# int 0x80), patch the GDT's TSS descriptor (gdt_start+40, see
# glue.s) with the TSS's actual runtime address, and load it with ltr.
.globl tss_init
tss_init:
    pushl %edi
    pushl %ecx

    movl  $tss_start, %edi
    movl  $104, %ecx
    xorl  %eax, %eax
.tss_zero_loop:
    movb  %al, (%edi)
    incl  %edi
    decl  %ecx
    jnz   .tss_zero_loop

    movl  $tss_kstack_top, tss_start+4     # ESP0
    movl  $0x10, tss_start+8               # SS0 = kernel data selector

    # patch gdt_start+40 (the TSS descriptor) with base=tss_start,
    # limit=103 (0x67) -- byte layout matches every other descriptor
    # in this kernel (see glue.s's gdt table, idt_init's gate-patching)
    movl  $tss_start, %eax
    movl  $(gdt_start+40), %ebx

    movb  $0x67, (%ebx)          # limit low
    movb  $0x00, 1(%ebx)         # limit high (low byte of the word)
    movb  %al, 2(%ebx)           # base 0:7
    movb  %ah, 3(%ebx)           # base 8:15
    shrl  $16, %eax
    movb  %al, 4(%ebx)           # base 16:23
    movb  $0x89, 5(%ebx)         # access: P=1,DPL=0,S=0,Type=1001 (32-bit TSS)
    movb  $0x00, 6(%ebx)         # granularity=0 (byte-granular limit), limit[19:16]=0
    movb  %ah, 7(%ebx)           # base 24:31 (ah now holds bits 24:31 after the shift)

    movw  $0x28, %ax
    ltr   %ax

    popl  %ecx
    popl  %edi
    ret

# jump_to_usermode(entry, user_stack) -- one-way transition to ring 3.
# Never returns to its caller in the normal sense; execution resumes
# in the shell task's own flow only if something later yields back
# into task 1's saved esp, which nothing in this file does.
.globl jump_to_usermode
jump_to_usermode:
    movl  4(%esp), %eax          # entry
    movl  8(%esp), %ecx          # user_stack

    movw  $0x23, %dx              # user data selector | RPL3 (0x20|3)
    movw  %dx, %ds
    movw  %dx, %es
    movw  %dx, %fs
    movw  %dx, %gs

    pushl $0x23                   # SS
    pushl %ecx                    # ESP
    pushfl
    orl   $0x200, (%esp)          # force IF=1 -- ring3 code runs with
                                   # interrupts enabled, same invariant
                                   # yield() enforces everywhere else
    pushl $0x1B                   # CS: user code selector | RPL3 (0x18|3)
    pushl %eax                    # EIP
    iret

# --- int 0x80 syscall gate -------------------------------------------
# Entered directly by the CPU via the IDT (vector 0x80, DPL=3 -- set
# in idt_init_syscall_gate below), not via one of isr_table's stubs,
# so there's no vec/err pushed ahead of the CPU's own frame the way
# isr_common_stub expects. Convention: eax = syscall number,
# ebx = arg1. Both are read back from the pusha'd copies below, not
# from the live registers, since %ax gets clobbered reloading segment
# selectors before we get to reading them.
.globl isr128
isr128:
    pusha
    movw  %ds, %ax
    pushl %eax
    movw  $0x10, %ax
    movw  %ax, %ds
    movw  %ax, %es
    movw  %ax, %fs
    movw  %ax, %gs

    # layout from esp upward: [0]=saved_ds [4]=edi [8]=esi [12]=ebp
    # [16]=esp(orig,unused) [20]=ebx [24]=edx [28]=ecx [32]=eax
    movl  32(%esp), %eax
    movl  20(%esp), %ebx
    pushl %ebx
    pushl %eax
    call  syscall_dispatch
    addl  $8, %esp

    popl  %eax
    movw  %ax, %ds
    movw  %ax, %es
    movw  %ax, %fs
    movw  %ax, %gs
    popa
    iret

# idt_set_syscall_gate() -- vector 0x80 needs DPL=3 (0xEE, not the
# usual 0x8E) so ring3 code is actually allowed to invoke it; every
# other gate idt_init() builds defaults to DPL=0, which would #GP a
# ring3 `int 0x80` instead of entering the handler. Called once from
# Falcon right after idt_init().
.globl idt_set_syscall_gate
idt_set_syscall_gate:
    pushl %ebx
    movl  $idt_start, %ebx
    addl  $(0x80 * 8), %ebx

    movl  $isr128, %eax
    movw  %ax, (%ebx)
    movw  $0x08, 2(%ebx)
    movb  $0x00, 4(%ebx)
    movb  $0xEE, 5(%ebx)         # present, DPL=3, 32-bit interrupt gate
    shrl  $16, %eax
    movw  %ax, 6(%ebx)

    popl  %ebx
    ret

# --- embedded ring-3 test program -------------------------------------
# Assembled separately (boot/usermode_test.s -> usermode_test.bin by
# the Makefile) and pulled in here as a raw blob. It's just machine
# code sitting in .rodata at this point -- nothing about these bytes
# makes them "ring 3"; what determines the privilege level at runtime
# is the CS selector active when they execute; usertest (shell.fl)
# copies them into a page it explicitly mapped with PAGE_USER before
# jumping there.
    .section .rodata
    .align 4
.globl user_test_blob_start
user_test_blob_start:
    .incbin "boot/usermode_test.bin"
.globl user_test_blob_end
user_test_blob_end:

    .section .text
.globl get_user_test_blob_info
get_user_test_blob_info:
    movl  $user_test_blob_start, _gv_g_user_test_blob_addr
    movl  $(user_test_blob_end - user_test_blob_start), _gv_g_user_test_blob_size
    ret
