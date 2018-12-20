SELECTOR_KERNEL_CS      equ     8   ; 8= 0x1000 idx=1 TI=0 RPL=0

extern  cstart
extern  exception_handler

extern  gdt_ptr
extern  idt_ptr
extern  disp_pos

[SECTION .bss]
StackSpace      resb    2 * 1024
StackTop:

[section .text]

global  _start

; interrupt
global divide_error
global single_step_exception
global nmi
global breakpoint_exception
global overflow
global bounds_check
global inval_opcode
global copr_not_available
global double_fault
global copr_seg_overrun
global inval_tss
global segment_not_present
global stack_exception
global general_protection
global page_fault
global copr_error

_start:
    mov     esp, StackTop

    mov     dword [disp_pos], 0

    sgdt    [gdt_ptr]
    call    cstart
    lgdt    [gdt_ptr]
    lidt    [idt_ptr]

    jmp     SELECTOR_KERNEL_CS:csinit

csinit:
    push    0
    popfd

    ud2     ; 制造一个异常

    hlt

divide_error:
    push    0xFFFFFFFF
    push    0
    jmp     exception
single_step_exception:
    push    0xFFFFFFFF
    push    1
    jmp     exception
nmi:
    push    0xFFFFFFFF
    push    2
    jmp     exception
breakpoint_exception:
    push    0xFFFFFFFF
    push    3
    jmp     exception
overflow:
    push    0xFFFFFFFF
    push    4
    jmp     exception
bounds_check:
    push    0xFFFFFFFF
    push    5
    jmp     exception
inval_opcode:
    push    0xFFFFFFFF
    push    6
    jmp     exception
copr_not_available:
    push    0xFFFFFFFF
    push    7
    jmp     exception
double_fault:
    push    0xFFFFFFFF
    push    8
    jmp     exception
copr_seg_overrun:
    push    0xFFFFFFFF
    push    9
    jmp     exception
inval_tss:
    push    0xFFFFFFFF
    push    10
    jmp     exception
segment_not_present:
    push    0xFFFFFFFF
    push    11
    jmp     exception
stack_exception:
    push    0xFFFFFFFF
    push    12
    jmp     exception
general_protection:
    push    0xFFFFFFFF
    push    13
    jmp     exception
page_fault:
    push    0xFFFFFFFF
    push    14
    jmp     exception
copr_error:
    push    0xFFFFFFFF
    push    16
    jmp     exception
exception:
    call    exception_handler
    add     esp, 4*2
    hlt
