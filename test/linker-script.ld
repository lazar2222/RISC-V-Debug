ENTRY(_start)

MEMORY
{
    SRAM (rwx) : ORIGIN = 0x00000000, LENGTH = 64K
}

SECTIONS
{
    . = 0x0000;
    PROVIDE (__executable_start = SEGMENT_START("text-segment", 0x00000)); 
    PROVIDE (__stack_pointer =  ORIGIN(SRAM) + LENGTH(SRAM) - 0x4);

    .ivt :
    {
        *(.ivt .ivt*)
    } > SRAM

    .text :
    {
        *(.startup .startup*)
        *(.text.startup .text.startup*)
        *(.text .text*)
    } > SRAM

    .rodata : 
    {
        *(.rodata .rodata*) 
    } > SRAM

    .data :
    {
        __DATA_BEGIN__ = .;
        *(.data .data*)
    } > SRAM

    .sdata :
    {
        __SDATA_BEGIN__ = .;
        *(.srodata .srodata*)
        *(.sdata .sdata*)
    } > SRAM

    _edata = .; PROVIDE (edata = .);
    . = .;
    . = ALIGN(32 / 8);
    __bss_start = .;

    .sbss :
    {
        *(.sbss .sbss*)
        *(.scommon)
    } > SRAM

    .bss :
    {
        *(.bss .bss*)
        *(COMMON)
        . = ALIGN(. != 0 ? 32 / 8 : 1);
    } > SRAM

    . = ALIGN(32 / 8);
    . = SEGMENT_START("ldata-segment", .);
    . = ALIGN(32 / 8);
    __BSS_END__ = .;
    __global_pointer$ = MIN(__SDATA_BEGIN__ + 0x800, MAX(__DATA_BEGIN__ + 0x800, __BSS_END__ - 0x800));
    _end = .; PROVIDE (end = .);

    .comment 0: 
    {
        *(.comment) 
    }

    .gnu.build.attributes : 
    {
        *(.gnu.build.attributes .gnu.build.attributes*)
    }
}

