/* link.ld — MerlinOS / Kestrel linker script */
OUTPUT_FORMAT(elf32-i386)
ENTRY(_start)

SECTIONS {
    . = 0x00100000;       /* 1 MiB — standard multiboot load address */

    .text ALIGN(4096) : {
        *(.multiboot)     /* multiboot header must be in the first 8KB */
        *(.text)
    }

    .rodata ALIGN(4096) : {
        *(.rodata*)
    }

    .data ALIGN(4096) : {
        *(.data)
    }

    .bss ALIGN(4096) : {
        *(COMMON)
        *(.bss)
    }

    /DISCARD/ : {
        *(.comment)
        *(.note*)
    }
}
