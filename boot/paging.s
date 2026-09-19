# paging.s — identity-mapped paging for Kestrel, stage 3
#
# 4 page tables (1024 entries each, 4 KiB pages) covering physical
# 0-16 MiB, mapped virtual == physical. That comfortably covers the
# kernel image, the bump heap (0x400000-0x800000), and everything the
# PMM currently hands out (frames start right after the kernel
# ceiling at 0x300000, see pmm.fl) with room to spare. Nothing here
# is a real virtual memory manager yet -- this just turns paging on
# without changing what any address means, so isr14 (#PF) becomes
# reachable and real instead of theoretical.

    .section .bss
    .align 4096
page_directory:
    .skip 4096
page_tables:
    .skip 4096 * 4      # 4 tables * 1024 entries * 4 bytes = 16 KiB

    .section .text
.globl paging_init
paging_init:
    pushl %ebx
    pushl %esi
    pushl %edi
    pushl %ecx

    # zero the page directory
    movl  $page_directory, %edi
    movl  $1024, %ecx
    xorl  %eax, %eax
.pg_zero_dir:
    movl  %eax, (%edi)
    addl  $4, %edi
    decl  %ecx
    jnz   .pg_zero_dir

    xorl  %esi, %esi            # esi = table index, 0..3
.pg_table_loop:
    cmpl  $4, %esi
    jge   .pg_tables_done

    movl  %esi, %ebx
    imull $4096, %ebx, %ebx
    addl  $page_tables, %ebx    # ebx = this table's address

    xorl  %ecx, %ecx            # ecx = entry index, 0..1023
.pg_entry_loop:
    cmpl  $1024, %ecx
    jge   .pg_entry_done

    movl  %esi, %eax            # physical page number = table*1024 + entry
    imull $1024, %eax, %eax
    addl  %ecx, %eax
    imull $4096, %eax, %eax     # -> physical address
    orl   $0x03, %eax           # present + read/write
    movl  %eax, (%ebx,%ecx,4)

    incl  %ecx
    jmp   .pg_entry_loop
.pg_entry_done:

    movl  %ebx, %eax
    orl   $0x03, %eax           # present + read/write
    movl  %eax, page_directory(,%esi,4)

    incl  %esi
    jmp   .pg_table_loop
.pg_tables_done:

    movl  $page_directory, %eax
    movl  %eax, %cr3

    movl  %cr0, %eax
    orl   $0x80000000, %eax
    movl  %eax, %cr0

    popl  %ecx
    popl  %edi
    popl  %esi
    popl  %ebx
    ret
