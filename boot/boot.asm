%include    "pm.inc.asm"
org     07c00h
    jmp     LABEL_BEGIN

[SECTION .gdt]
;                                   段基址      段界限      属性
LABEL_GDT:              Descriptor       0,             0,      0
LABEL_DESC_CODE32:      Descriptor       0,SegCode32Len-1, DA_C + DA_32
LABEL_DESC_VIDEO:       Descriptor 0B8000h,        0ffffh, DA_DRW
GdtLen      equ     $ - LABEL_GDT
GdtPtr      dw      GdtLen - 1
            dd      0
SelectorCode32      equ     LABEL_DESC_CODE32       - LABEL_GDT
SelectorVideo       equ     LABEL_DESC_VIDEO        - LABEL_GDT

[SECTION .s16]
[BITS 16]
LABEL_BEGIN:
    mov     ax, cs
    mov     ds, ax
    mov     es, ax
    mov     ss, ax
    mov     sp, 0100h

    ; init descriptor code32
    xor     eax, eax                            ; 清空eax
    mov     ax, cs                              ; eax = 段基址
    shl     eax, 4                              ; 段基址 * 16
    add     eax, LABEL_SEG_CODE32               ; 加上偏移量
    mov     word [LABEL_DESC_CODE32 + 2], ax    ; 将计算好的32位代码段地址赋给代码段的描述符
    shr     eax, 16
    mov     byte [LABEL_DESC_CODE32 + 4], al
    mov     byte [LABEL_DESC_CODE32 + 7], ah

    xor     eax, eax
    mov     ax, ds
    shl     eax, 4
    add     eax, LABEL_GDT
    mov     dword [GdtPtr + 2], eax

    lgdt    [GdtPtr]

    cli

    in      al, 92h
    or      al, 00000010b
    out     92h, al

    mov     eax, cr0
    or      eax, 1
    mov     cr0, eax

    jmp     dword SelectorCode32:0

[SECTION .s32]
[BITS 32]
LABEL_SEG_CODE32:
    mov     ax, SelectorVideo
    mov     gs, ax

    mov     edi, (80 * 11 + 79) * 2
    mov     ah, 0Ch
    mov     al, 'p'
    mov     [gs:edi], ax

    jmp     $
SegCode32Len    equ     $ - LABEL_SEG_CODE32

; 为了使生成的镜像符合boot sector的约定
db      0           ; 用于补齐
times   512     dw      0xaa55