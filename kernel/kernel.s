.section .text

.globl kheap_init
kheap_init:
    pushl %ebp
    movl %esp,%ebp
    pushl %esi
    pushl %edi
    pushl %ebx
    movl $4194304,%eax
    movl %eax,_gv_g_kheap_ptr
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret

.globl _flr_alloc
_flr_alloc:
    pushl %ebp
    movl %esp,%ebp
    subl $16,%esp
    pushl %esi
    pushl %edi
    pushl %ebx
    movl _gv_g_kheap_ptr,%eax
    movl %eax,-4(%ebp)
    movl $15,%eax
    notl %eax
    pushl %eax
    movl $15,%eax
    pushl %eax
    movl 8(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    popl %ecx
    andl %ecx,%eax
    movl %eax,-8(%ebp)
    movl -8(%ebp),%eax
    pushl %eax
    movl _gv_g_kheap_ptr,%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,_gv_g_kheap_ptr
    movl -4(%ebp),%eax
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret

.globl _flr_free
_flr_free:
    pushl %ebp
    movl %esp,%ebp
    pushl %esi
    pushl %edi
    pushl %ebx
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret

.globl kstrlen
kstrlen:
    pushl %ebp
    movl %esp,%ebp
    subl $16,%esp
    pushl %esi
    pushl %edi
    pushl %ebx
    movl $0,%eax
    movl %eax,-4(%ebp)
.Lwh0:
    movl $0,%eax
    pushl %eax
    movl -4(%ebp),%eax
    pushl %eax
    movl 8(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    movzbl (%eax),%eax
    popl %ecx
    cmpl %ecx,%eax
    setne %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lwh1
    movl $1,%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,-4(%ebp)
    jmp .Lwh0
.Lwh1:
    movl -4(%ebp),%eax
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret

.globl kstreq
kstreq:
    pushl %ebp
    movl %esp,%ebp
    subl $16,%esp
    pushl %esi
    pushl %edi
    pushl %ebx
    movl $0,%eax
    movl %eax,-4(%ebp)
.Lwh2:
    movl $1,%eax
    testl %eax,%eax
    je .Lwh3
    movl -4(%ebp),%eax
    pushl %eax
    movl 8(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    movzbl (%eax),%eax
    movl %eax,-8(%ebp)
    movl -4(%ebp),%eax
    pushl %eax
    movl 12(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    movzbl (%eax),%eax
    movl %eax,-12(%ebp)
    movl -12(%ebp),%eax
    pushl %eax
    movl -8(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    setne %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lif5
    movl $0,%eax
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret
    jmp .Lif4
.Lif5:
.Lif4:
    movl $0,%eax
    pushl %eax
    movl -8(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    sete %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lif7
    movl $1,%eax
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret
    jmp .Lif6
.Lif7:
.Lif6:
    movl $1,%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,-4(%ebp)
    jmp .Lwh2
.Lwh3:
    movl $1,%eax
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret

.globl kmemset
kmemset:
    pushl %ebp
    movl %esp,%ebp
    subl $16,%esp
    pushl %esi
    pushl %edi
    pushl %ebx
    movl $0,%eax
    movl %eax,-4(%ebp)
.Lwh8:
    movl 16(%ebp),%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    setl %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lwh9
    movl 12(%ebp),%eax
    pushl %eax
    movl -4(%ebp),%eax
    pushl %eax
    movl 8(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    popl %ecx
    movb %cl,(%eax)
    xorl %eax,%eax
    movl $1,%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,-4(%ebp)
    jmp .Lwh8
.Lwh9:
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret

.globl kmemcpy
kmemcpy:
    pushl %ebp
    movl %esp,%ebp
    subl $16,%esp
    pushl %esi
    pushl %edi
    pushl %ebx
    movl $0,%eax
    movl %eax,-4(%ebp)
.Lwh10:
    movl 16(%ebp),%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    setl %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lwh11
    movl -4(%ebp),%eax
    pushl %eax
    movl 12(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    movzbl (%eax),%eax
    pushl %eax
    movl -4(%ebp),%eax
    pushl %eax
    movl 8(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    popl %ecx
    movb %cl,(%eax)
    xorl %eax,%eax
    movl $1,%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,-4(%ebp)
    jmp .Lwh10
.Lwh11:
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret

.globl vga_set_color
vga_set_color:
    pushl %ebp
    movl %esp,%ebp
    pushl %esi
    pushl %edi
    pushl %ebx
    movl 8(%ebp),%eax
    movl %eax,_gv_g_vga_attr
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret

.globl vga_clear
vga_clear:
    pushl %ebp
    movl %esp,%ebp
    subl $16,%esp
    pushl %esi
    pushl %edi
    pushl %ebx
    movl $753664,%eax
    movl %eax,-4(%ebp)
    movl $2,%eax
    pushl %eax
    movl $25,%eax
    pushl %eax
    movl $80,%eax
    popl %ecx
    imull %ecx,%eax
    popl %ecx
    imull %ecx,%eax
    pushl %eax
    movl $753664,%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,-8(%ebp)
.Lwh12:
    movl -8(%ebp),%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    setl %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lwh13
    movl $32,%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    movb %cl,(%eax)
    xorl %eax,%eax
    movl $15,%eax
    pushl %eax
    movl $1,%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    popl %ecx
    movb %cl,(%eax)
    xorl %eax,%eax
    movl $2,%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,-4(%ebp)
    jmp .Lwh12
.Lwh13:
    movl $0,%eax
    movl %eax,_gv_g_vga_row
    movl $0,%eax
    movl %eax,_gv_g_vga_col
    movl $15,%eax
    movl %eax,_gv_g_vga_attr
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret

.globl vga_scroll
vga_scroll:
    pushl %ebp
    movl %esp,%ebp
    subl $32,%esp
    pushl %esi
    pushl %edi
    pushl %ebx
    movl $2,%eax
    pushl %eax
    movl $80,%eax
    popl %ecx
    imull %ecx,%eax
    movl %eax,-4(%ebp)
    movl -4(%ebp),%eax
    pushl %eax
    movl $753664,%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,-8(%ebp)
    movl $753664,%eax
    movl %eax,-12(%ebp)
    movl $24,%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    imull %ecx,%eax
    movl %eax,-16(%ebp)
    movl -16(%ebp),%eax
    pushl %eax
    movl -8(%ebp),%eax
    pushl %eax
    movl -12(%ebp),%eax
    pushl %eax
    call kmemcpy
    addl $12,%esp
    movl $24,%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    imull %ecx,%eax
    pushl %eax
    movl $753664,%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,-20(%ebp)
    movl -4(%ebp),%eax
    pushl %eax
    movl -20(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,-24(%ebp)
    movl -20(%ebp),%eax
    movl %eax,-28(%ebp)
.Lwh14:
    movl -24(%ebp),%eax
    pushl %eax
    movl -28(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    setl %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lwh15
    movl $32,%eax
    pushl %eax
    movl -28(%ebp),%eax
    popl %ecx
    movb %cl,(%eax)
    xorl %eax,%eax
    movl $15,%eax
    pushl %eax
    movl $1,%eax
    pushl %eax
    movl -28(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    popl %ecx
    movb %cl,(%eax)
    xorl %eax,%eax
    movl $2,%eax
    pushl %eax
    movl -28(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,-28(%ebp)
    jmp .Lwh14
.Lwh15:
    movl $24,%eax
    movl %eax,_gv_g_vga_row
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret

.globl vga_newline
vga_newline:
    pushl %ebp
    movl %esp,%ebp
    pushl %esi
    pushl %edi
    pushl %ebx
    movl $0,%eax
    movl %eax,_gv_g_vga_col
    movl $1,%eax
    pushl %eax
    movl _gv_g_vga_row,%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,_gv_g_vga_row
    movl $25,%eax
    pushl %eax
    movl _gv_g_vga_row,%eax
    popl %ecx
    cmpl %ecx,%eax
    setge %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lif17
    call vga_scroll
    jmp .Lif16
.Lif17:
.Lif16:
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret

.globl vga_putc
vga_putc:
    pushl %ebp
    movl %esp,%ebp
    subl $16,%esp
    pushl %esi
    pushl %edi
    pushl %ebx
    movl $10,%eax
    pushl %eax
    movl 8(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    sete %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lif19
    call vga_newline
    xorl %eax,%eax
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret
    jmp .Lif18
.Lif19:
.Lif18:
    movl $2,%eax
    pushl %eax
    movl _gv_g_vga_col,%eax
    pushl %eax
    movl $80,%eax
    pushl %eax
    movl _gv_g_vga_row,%eax
    popl %ecx
    imull %ecx,%eax
    popl %ecx
    addl %ecx,%eax
    popl %ecx
    imull %ecx,%eax
    movl %eax,-4(%ebp)
    movl -4(%ebp),%eax
    pushl %eax
    movl $753664,%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,-8(%ebp)
    movl 8(%ebp),%eax
    pushl %eax
    movl -8(%ebp),%eax
    popl %ecx
    movb %cl,(%eax)
    xorl %eax,%eax
    movl _gv_g_vga_attr,%eax
    pushl %eax
    movl $1,%eax
    pushl %eax
    movl -8(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    popl %ecx
    movb %cl,(%eax)
    xorl %eax,%eax
    movl $1,%eax
    pushl %eax
    movl _gv_g_vga_col,%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,_gv_g_vga_col
    movl $80,%eax
    pushl %eax
    movl _gv_g_vga_col,%eax
    popl %ecx
    cmpl %ecx,%eax
    setge %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lif21
    call vga_newline
    jmp .Lif20
.Lif21:
.Lif20:
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret

.globl vga_print
vga_print:
    pushl %ebp
    movl %esp,%ebp
    subl $16,%esp
    pushl %esi
    pushl %edi
    pushl %ebx
    movl $0,%eax
    movl %eax,-4(%ebp)
.Lwh22:
    movl $1,%eax
    testl %eax,%eax
    je .Lwh23
    movl -4(%ebp),%eax
    pushl %eax
    movl 8(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    movzbl (%eax),%eax
    movl %eax,-8(%ebp)
    movl $0,%eax
    pushl %eax
    movl -8(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    sete %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lif25
    jmp .Lwh23
    jmp .Lif24
.Lif25:
.Lif24:
    movl -8(%ebp),%eax
    pushl %eax
    call vga_putc
    addl $4,%esp
    movl $1,%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,-4(%ebp)
    jmp .Lwh22
.Lwh23:
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret

.globl vga_print_hex
vga_print_hex:
    pushl %ebp
    movl %esp,%ebp
    subl $16,%esp
    pushl %esi
    pushl %edi
    pushl %ebx
    movl $48,%eax
    pushl %eax
    call vga_putc
    addl $4,%esp
    movl $120,%eax
    pushl %eax
    call vga_putc
    addl $4,%esp
    movl $28,%eax
    movl %eax,-4(%ebp)
    movl $0,%eax
    movl %eax,-8(%ebp)
.Lwh26:
    movl $0,%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    setge %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lwh27
    movl $15,%eax
    pushl %eax
    movl -4(%ebp),%eax
    pushl %eax
    movl 8(%ebp),%eax
    popl %ecx
    sarl %cl,%eax
    popl %ecx
    andl %ecx,%eax
    movl %eax,-12(%ebp)
    movl $0,%eax
    pushl %eax
    movl -12(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    setne %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lif29
    movl $1,%eax
    movl %eax,-8(%ebp)
    jmp .Lif28
.Lif29:
.Lif28:
    movl $0,%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    sete %al
    movzbl %al,%eax
    pushl %eax
    movl -8(%ebp),%eax
    popl %ecx
    orl %ecx,%eax
    setne %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lif31
    movl $10,%eax
    pushl %eax
    movl -12(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    setl %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lif33
    movl -12(%ebp),%eax
    pushl %eax
    movl $48,%eax
    popl %ecx
    addl %ecx,%eax
    pushl %eax
    call vga_putc
    addl $4,%esp
    jmp .Lif32
.Lif33:
    movl $10,%eax
    pushl %eax
    movl -12(%ebp),%eax
    popl %ecx
    subl %ecx,%eax
    pushl %eax
    movl $97,%eax
    popl %ecx
    addl %ecx,%eax
    pushl %eax
    call vga_putc
    addl $4,%esp
.Lif32:
    jmp .Lif30
.Lif31:
.Lif30:
    movl $4,%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    subl %ecx,%eax
    movl %eax,-4(%ebp)
    jmp .Lwh26
.Lwh27:
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret

.globl vga_print_dec
vga_print_dec:
    pushl %ebp
    movl %esp,%ebp
    subl $32,%esp
    pushl %esi
    pushl %edi
    pushl %ebx
    movl $0,%eax
    pushl %eax
    movl 8(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    sete %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lif35
    movl $48,%eax
    pushl %eax
    call vga_putc
    addl $4,%esp
    xorl %eax,%eax
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret
    jmp .Lif34
.Lif35:
.Lif34:
    movl $0,%eax
    movl %eax,-4(%ebp)
    movl 8(%ebp),%eax
    movl %eax,-8(%ebp)
    movl $0,%eax
    pushl %eax
    movl -8(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    setl %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lif37
    movl $1,%eax
    movl %eax,-4(%ebp)
    movl -8(%ebp),%eax
    pushl %eax
    movl $0,%eax
    popl %ecx
    subl %ecx,%eax
    movl %eax,-8(%ebp)
    jmp .Lif36
.Lif37:
.Lif36:
    pushl $56
    call _flr_alloc
    addl $4,%esp
    pushl %eax
    movl $12,(%eax)
    movl $12,4(%eax)
    movl (%esp),%edi
    movl $0,%eax
    movl %eax,8(%edi)
    movl (%esp),%edi
    movl $0,%eax
    movl %eax,12(%edi)
    movl (%esp),%edi
    movl $0,%eax
    movl %eax,16(%edi)
    movl (%esp),%edi
    movl $0,%eax
    movl %eax,20(%edi)
    movl (%esp),%edi
    movl $0,%eax
    movl %eax,24(%edi)
    movl (%esp),%edi
    movl $0,%eax
    movl %eax,28(%edi)
    movl (%esp),%edi
    movl $0,%eax
    movl %eax,32(%edi)
    movl (%esp),%edi
    movl $0,%eax
    movl %eax,36(%edi)
    movl (%esp),%edi
    movl $0,%eax
    movl %eax,40(%edi)
    movl (%esp),%edi
    movl $0,%eax
    movl %eax,44(%edi)
    movl (%esp),%edi
    movl $0,%eax
    movl %eax,48(%edi)
    movl (%esp),%edi
    movl $0,%eax
    movl %eax,52(%edi)
    popl %eax
    movl %eax,-12(%ebp)
    movl $0,%eax
    movl %eax,-16(%ebp)
.Lwh38:
    movl $0,%eax
    pushl %eax
    movl -8(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    setg %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lwh39
    movl $10,%eax
    pushl %eax
    movl -8(%ebp),%eax
    popl %ecx
    cdq
    idivl %ecx
    movl %edx,%eax
    pushl %eax
    movl -16(%ebp),%eax
    pushl %eax
    movl -12(%ebp),%eax
    popl %ecx
    leal 8(%eax,%ecx,4),%edx
    popl %eax
    movl %eax,(%edx)
    movl $10,%eax
    pushl %eax
    movl -8(%ebp),%eax
    popl %ecx
    cdq
    idivl %ecx
    movl %eax,-8(%ebp)
    movl $1,%eax
    pushl %eax
    movl -16(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,-16(%ebp)
    jmp .Lwh38
.Lwh39:
    movl -4(%ebp),%eax
    testl %eax,%eax
    je .Lif41
    movl $45,%eax
    pushl %eax
    call vga_putc
    addl $4,%esp
    jmp .Lif40
.Lif41:
.Lif40:
    movl $1,%eax
    pushl %eax
    movl -16(%ebp),%eax
    popl %ecx
    subl %ecx,%eax
    movl %eax,-20(%ebp)
.Lwh42:
    movl $0,%eax
    pushl %eax
    movl -20(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    setge %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lwh43
    movl -20(%ebp),%eax
    pushl %eax
    movl -12(%ebp),%eax
    popl %ecx
    leal 8(%eax,%ecx,4),%eax
    movl (%eax),%eax
    pushl %eax
    movl $48,%eax
    popl %ecx
    addl %ecx,%eax
    pushl %eax
    call vga_putc
    addl $4,%esp
    movl $1,%eax
    pushl %eax
    movl -20(%ebp),%eax
    popl %ecx
    subl %ecx,%eax
    movl %eax,-20(%ebp)
    jmp .Lwh42
.Lwh43:
    popl %ebx
    popl %edi
    popl %esi
    leave
    ret

.globl main
main:
    pushl %ebp
    movl %esp,%ebp
    subl $16,%esp
    pushl %esi
    pushl %edi
    pushl %ebx
    call kheap_init
    call vga_clear
    movl $15,%eax
    pushl %eax
    call vga_set_color
    addl $4,%esp
    leal .Lstr0,%eax
    pushl %eax
    call vga_print
    addl $4,%esp
    movl $7,%eax
    pushl %eax
    call vga_set_color
    addl $4,%esp
    leal .Lstr1,%eax
    pushl %eax
    call vga_print
    addl $4,%esp
    movl $10,%eax
    pushl %eax
    call vga_set_color
    addl $4,%esp
    leal .Lstr2,%eax
    pushl %eax
    call vga_print
    addl $4,%esp
    leal .Lstr3,%eax
    pushl %eax
    call vga_print
    addl $4,%esp
    movl $4194304,%eax
    pushl %eax
    call vga_print_hex
    addl $4,%esp
    leal .Lstr4,%eax
    pushl %eax
    call vga_print
    addl $4,%esp
    pushl $24
    call _flr_alloc
    addl $4,%esp
    pushl %eax
    movl $4,(%eax)
    movl $4,4(%eax)
    movl (%esp),%edi
    movl $10,%eax
    movl %eax,8(%edi)
    movl (%esp),%edi
    movl $20,%eax
    movl %eax,12(%edi)
    movl (%esp),%edi
    movl $30,%eax
    movl %eax,16(%edi)
    movl (%esp),%edi
    movl $40,%eax
    movl %eax,20(%edi)
    popl %eax
    movl %eax,-4(%ebp)
    movl $0,%eax
    movl %eax,-8(%ebp)
    movl $0,%eax
    movl %eax,-12(%ebp)
.Lwh44:
    movl $4,%eax
    pushl %eax
    movl -12(%ebp),%eax
    popl %ecx
    cmpl %ecx,%eax
    setl %al
    movzbl %al,%eax
    testl %eax,%eax
    je .Lwh45
    movl -12(%ebp),%eax
    pushl %eax
    movl -4(%ebp),%eax
    popl %ecx
    leal 8(%eax,%ecx,4),%eax
    movl (%eax),%eax
    pushl %eax
    movl -8(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,-8(%ebp)
    movl $1,%eax
    pushl %eax
    movl -12(%ebp),%eax
    popl %ecx
    addl %ecx,%eax
    movl %eax,-12(%ebp)
    jmp .Lwh44
.Lwh45:
    movl $15,%eax
    pushl %eax
    call vga_set_color
    addl $4,%esp
    leal .Lstr5,%eax
    pushl %eax
    call vga_print
    addl $4,%esp
    movl -8(%ebp),%eax
    pushl %eax
    call vga_print_dec
    addl $4,%esp
    leal .Lstr4,%eax
    pushl %eax
    call vga_print
    addl $4,%esp
    movl $8,%eax
    pushl %eax
    call vga_set_color
    addl $4,%esp
    leal .Lstr6,%eax
    pushl %eax
    call vga_print
    addl $4,%esp
    popl %ebx
    popl %edi
    popl %esi
    cli
.Lhlt_loop:
    hlt
    jmp .Lhlt_loop

.section .data
.section .rodata
.Lstr0:
    .ascii "MerlinOS\n\0"
.Lstr1:
    .ascii "Kestrel kernel -- stage 0\n\n\0"
.Lstr2:
    .ascii "[ok] VGA text driver\n\0"
.Lstr3:
    .ascii "[ok] kernel heap at \0"
.Lstr4:
    .ascii "\n\0"
.Lstr5:
    .ascii "[ok] heap alloc + array test, sum = \0"
.Lstr6:
    .ascii "\nsystem idle.\n\0"
.Lfl_zero:
    .long 0
    .long 0
.section .data
.globl _gv_g_kheap_ptr
_gv_g_kheap_ptr:
    .long 0
.globl _gv_g_vga_row
_gv_g_vga_row:
    .long 0
.globl _gv_g_vga_col
_gv_g_vga_col:
    .long 0
.globl _gv_g_vga_attr
_gv_g_vga_attr:
    .long 0
