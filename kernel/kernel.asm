SELECTOR_KERNEL_CS      equ     8   ; 8= 0x1000 idx=1 TI=0 RPL=0

extern  cstart

extern  gdt_ptr

[SECTION .bss]
StackSpace      resb    2 * 1024
StackTop

[section .text]

global  _start

_start:
    mov     esp, StackTop

    sgdt    [gdt_ptr]
    call    cstart
    lgdt    [gdt_ptr]

    jmp     SELECTOR_KERNEL_CS:csinit

csinit:
    push    0
    popfd

    hlt
