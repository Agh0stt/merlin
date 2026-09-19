# ata.s — ATA PIO disk driver, primary bus, master drive
#
# 28-bit LBA, one 512-byte sector per call. Pure asm rather than
# Falcon for one concrete reason: the data register (0x1F0) has to be
# accessed as 16-bit words, and falconc's __inb/__outb intrinsics are
# byte-width only. There's no __inw/__outw to call from Falcon, and
# faking a word read as two byte reads to the same port is not
# something ATA controllers are guaranteed to handle correctly --
# `rep insw`/`rep outsw` is the actually-correct way to do this
# transfer, so the whole operation lives here rather than splitting
# the register setup (which Falcon *could* do via __outb) from the
# data transfer (which it can't). Keeping one operation in one place
# beats splitting it across a language boundary for no real benefit.
#
# Every BSY/DRQ poll loop is bounded (~2,000,000 iterations) rather
# than spinning forever. Without that, booting with no disk attached
# -- entirely plausible the first time anyone runs this -- would hang
# the machine solid the moment anything touched the filesystem, since
# a missing drive never sets DRQ. A bounded wait fails ugly instead of
# hanging forever; there's still no error reporting back to Falcon on
# timeout (the caller just gets whatever garbage was in the buffer),
# which is the next thing worth adding here, not a reason to block on
# it now.
#
# No error-bit checking on the status register yet -- a real driver
# would check ERR (0x01) after DRQ and read the error register on
# failure. Missing entirely here; treat these as happy-path only
# until that's added.

    .section .text

# ata_read_sector(lba, buf_ptr) -- reads 512 bytes into buf_ptr.
.globl ata_read_sector
ata_read_sector:
    pushl %ebp
    movl  %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi

    movl  12(%ebp), %edi        # buf_ptr -- destination for rep insw

    movl  8(%ebp), %eax
    shrl  $24, %eax
    andl  $0x0F, %eax
    orl   $0xE0, %eax
    movl  $0x1F6, %edx
    outb  %al, %dx              # drive/head: master, LBA mode, LBA[27:24]

    movl  $0x1F2, %edx
    movb  $1, %al
    outb  %al, %dx              # sector count = 1

    movl  8(%ebp), %eax
    movl  $0x1F3, %edx
    outb  %al, %dx              # LBA[7:0]

    movl  8(%ebp), %eax
    shrl  $8, %eax
    movl  $0x1F4, %edx
    outb  %al, %dx              # LBA[15:8]

    movl  8(%ebp), %eax
    shrl  $16, %eax
    movl  $0x1F5, %edx
    outb  %al, %dx              # LBA[23:16]

    movl  $0x1F7, %edx
    movb  $0x20, %al            # READ SECTORS (28-bit)
    outb  %al, %dx

.ata_rd_wait_bsy:
    movl  $2000000, %ecx
.ata_rd_wait_bsy_loop:
    inb   %dx, %al
    testb $0x80, %al
    jz    .ata_rd_bsy_done
    decl  %ecx
    jnz   .ata_rd_wait_bsy_loop
.ata_rd_bsy_done:
    movl  $2000000, %ecx
.ata_rd_wait_drq_loop:
    inb   %dx, %al
    testb $0x08, %al
    jnz   .ata_rd_drq_done
    decl  %ecx
    jnz   .ata_rd_wait_drq_loop
.ata_rd_drq_done:

    movl  $0x1F0, %edx
    movl  $256, %ecx
    cld
    rep   insw                  # 256 words = 512 bytes, into ES:EDI

    popl  %edi
    popl  %esi
    popl  %ebx
    popl  %ebp
    ret

# ata_write_sector(lba, buf_ptr) -- writes 512 bytes from buf_ptr,
# then flushes the drive's write cache before returning.
.globl ata_write_sector
ata_write_sector:
    pushl %ebp
    movl  %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi

    movl  12(%ebp), %esi        # buf_ptr -- source for rep outsw

    movl  8(%ebp), %eax
    shrl  $24, %eax
    andl  $0x0F, %eax
    orl   $0xE0, %eax
    movl  $0x1F6, %edx
    outb  %al, %dx

    movl  $0x1F2, %edx
    movb  $1, %al
    outb  %al, %dx

    movl  8(%ebp), %eax
    movl  $0x1F3, %edx
    outb  %al, %dx

    movl  8(%ebp), %eax
    shrl  $8, %eax
    movl  $0x1F4, %edx
    outb  %al, %dx

    movl  8(%ebp), %eax
    shrl  $16, %eax
    movl  $0x1F5, %edx
    outb  %al, %dx

    movl  $0x1F7, %edx
    movb  $0x30, %al            # WRITE SECTORS (28-bit)
    outb  %al, %dx

.ata_wr_wait_bsy1:
    movl  $2000000, %ecx
.ata_wr_wait_bsy1_loop:
    inb   %dx, %al
    testb $0x80, %al
    jz    .ata_wr_bsy1_done
    decl  %ecx
    jnz   .ata_wr_wait_bsy1_loop
.ata_wr_bsy1_done:
    movl  $2000000, %ecx
.ata_wr_wait_drq_loop:
    inb   %dx, %al
    testb $0x08, %al
    jnz   .ata_wr_drq_done
    decl  %ecx
    jnz   .ata_wr_wait_drq_loop
.ata_wr_drq_done:

    movl  $0x1F0, %edx
    movl  $256, %ecx
    cld
    rep   outsw

    movl  $0x1F7, %edx
    movl  $2000000, %ecx
.ata_wr_wait_bsy2_loop:
    inb   %dx, %al
    testb $0x80, %al
    jz    .ata_wr_bsy2_done
    decl  %ecx
    jnz   .ata_wr_wait_bsy2_loop
.ata_wr_bsy2_done:

    movb  $0xE7, %al            # FLUSH CACHE
    outb  %al, %dx
    movl  $2000000, %ecx
.ata_wr_wait_bsy3_loop:
    inb   %dx, %al
    testb $0x80, %al
    jz    .ata_wr_bsy3_done
    decl  %ecx
    jnz   .ata_wr_wait_bsy3_loop
.ata_wr_bsy3_done:

    popl  %edi
    popl  %esi
    popl  %ebx
    popl  %ebp
    ret
