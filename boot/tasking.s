# tasking.s — cooperative task switching, stage 6
#
# Deliberately NOT preemptive: nothing here ever switches tasks from
# inside an interrupt handler. yield() is called voluntarily. Getting
# preemption right means saving/restoring a full iret frame (not just
# a pusha frame) from inside irq_common_stub, which is meaningfully
# harder to get right without a way to single-step and verify it --
# cooperative switching is the honest scope for what this project can
# currently test with confidence, and it's entirely sufficient for
# "a shell task that yields while waiting on keyboard input."
#
# Only two tasks exist: task 0 is whichever execution context first
# runs (main() itself, playing the idle role), task 1 is the shell,
# whose initial stack is built once by task_spawn_shell(). Falcon has
# no address-of operator and no way to get a raw pointer out of an
# array variable (confirmed empirically, not assumed), so the
# per-task saved-esp bookkeeping lives here as plain asm globals
# rather than something Falcon manages -- Falcon only ever calls
# yield() and task_spawn_shell(stack_top), both of which take/return
# nothing but plain integer values.

    .section .data
    .align 4
g_task_esp:
    .long 0, 0
g_current_task:
    .long 0

    .section .text

# yield() -- save the calling task's full register state on its own
# stack, swap to the other task's saved esp, restore its state, and
# return -- to the caller of ITS most recent yield() call, not to
# whoever called yield() this time. That's the entire trick behind
# stack-based cooperative switching: "returning" from this call can
# land in a completely different task than the one that entered it.
.globl yield
yield:
    pushf
    # Force IF=1 in the saved copy, unconditionally, regardless of
    # what it actually was at the moment of the call. This matters
    # because the timer's irq_handler calls yield() directly on every
    # timer tick to force preemption -- and entering an interrupt gate
    # auto-clears IF, so without this fix a task preempted mid-tick
    # would resume, later, with interrupts permanently disabled. Every
    # task in this kernel is meant to run with interrupts enabled the
    # entire time it's not itself inside a handler; baking that
    # invariant in here means yield() is safe to call from anywhere,
    # cooperative or not, without the caller having to think about it.
    orl   $0x200, (%esp)
    pusha

    movl  g_current_task, %eax
    movl  %esp, g_task_esp(,%eax,4)

    xorl  $1, %eax
    movl  %eax, g_current_task
    movl  g_task_esp(,%eax,4), %esp

    popa
    popf
    ret

# task_spawn_shell(stack_top) -- build task 1's initial stack so its
# first switch-in behaves exactly like a normal call into shell_task:
# a fake pusha frame (zeroed -- initial register values don't matter),
# a fake eflags (0x202: reserved bit + IF set, matching the fact that
# interrupts are already enabled by the time this ever gets scheduled),
# and a fake "return address" that IS the real entry point. yield()'s
# own popa/popf/ret sequence can't tell this apart from a task it
# switched out of normally.
.globl task_spawn_shell
task_spawn_shell:
    movl  4(%esp), %eax
    subl  $40, %eax

    movl  $0, 0(%eax)
    movl  $0, 4(%eax)
    movl  $0, 8(%eax)
    movl  $0, 12(%eax)
    movl  $0, 16(%eax)
    movl  $0, 20(%eax)
    movl  $0, 24(%eax)
    movl  $0, 28(%eax)
    movl  $0x202, 32(%eax)
    movl  $shell_task, 36(%eax)

    movl  %eax, g_task_esp+4

    ret
