# usermode_test.s — the actual code that runs at ring 3.
#
# Assembled and objcopy'd into a raw flat binary by the Makefile
# (usermode_test.bin), then pulled into the kernel image as a data
# blob by usermode.s's .incbin -- these bytes are never executed as
# part of the kernel's own control flow. shell.fl's `usertest` command
# copies them into a page it has explicitly mapped with PAGE_USER
# before ever jumping there; nothing about the bytes themselves makes
# them privileged or unprivileged, only the CS in effect when they run.
#
# Deliberately tiny: three syscalls to print "Hi\n" one character at a
# time (proving the syscall path actually works, not just that ring 3
# execution doesn't immediately fault), then a SYS_EXIT syscall that
# halts the machine. No stack frame setup, no called functions, no
# libc -- there isn't one. Convention: eax = syscall number,
# ebx = arg1. SYS_WRITE_CHAR=1, SYS_EXIT=2 (see syscall.fl).

.section .text
.globl _user_entry
_user_entry:
    movl  $72, %ebx        # 'H'
    movl  $1, %eax
    int   $0x80

    movl  $105, %ebx       # 'i'
    movl  $1, %eax
    int   $0x80

    movl  $10, %ebx        # '\n'
    movl  $1, %eax
    int   $0x80

    movl  $2, %eax          # SYS_EXIT
    int   $0x80

.hang:
    jmp   .hang              # never reached -- SYS_EXIT halts the
                              # machine -- but a stray fall-through
                              # into unmapped memory is a worse failure
                              # mode than an infinite jmp, so this stays
