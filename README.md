# MerlinOS

A bare-metal x86 OS written in [Falcon](falcon/), a custom C-like
language. The kernel is called **Kestrel**.

## Build & run

```
make iso        # build kestrel.elf, wrap in a GRUB ISO (merlinos.iso)
make run        # boot merlinos.iso in QEMU
make run-direct # skip GRUB, boot kestrel.elf directly via QEMU -kernel
```

Requires `gcc`, 32-bit-capable `binutils`, `grub-mkrescue`, `xorriso`,
`mtools`, and `qemu-system-i386` for `make run`.

## Layout

```
falcon/           the Falcon compiler (falconc.c), vendored
boot/boot.s       multiboot header, _start, stack setup, calls main()
boot/link.ld      linker script — loads at 1 MiB
boot/grub.cfg     GRUB menu entry
kernel/kernel.fl  Kestrel entry point (main)
kernel/kstd.fl    freestanding runtime: bump allocator, string/mem helpers
kernel/vga.fl     VGA text-mode driver
```

## Why kstd.fl exists

Falcon's `--freestanding` mode strips the hosted runtime (`flr.o`), but
arrays, structs, and the `__memset`/`__memcpy` intrinsics still compile
down to calls into runtime symbols (`_flr_alloc`, `_flr_memset`,
`_flr_memcpy`) that no longer exist. `kstd.fl` reimplements the ones
Kestrel needs, in Falcon itself, as a bump allocator over a fixed
4 MiB heap region plus plain byte-loop mem helpers.

**Global variable initializers are dropped in `--freestanding`** —
every global always starts at zero, regardless of its declared
initializer. Anything that needs a real starting value (heap pointer,
VGA cursor state, VGA attribute byte) is set explicitly by an init
function called at the very top of `main()`, never trusted to its
declaration.

## Status: Stage 0

Boots via GRUB, clears the VGA text buffer, prints a banner, and runs
a self-test that exercises the heap allocator and array codegen.

Next: GDT/IDT + exception handlers, PIC remap + PIT, PS/2 keyboard,
then a shell.
