%include    "pm.inc.asm"
%ifdef _BUILD_COM_
    org     0100h 
%else
    org     07c00h
%endif
    jmp     LABEL_BEGIN

[SECTION .gdt]
;                                   段基址      段界限      属性
LABEL_GDT:              Descriptor       0,             0,      0
LABEL_DESC_NORMAL:      Descriptor       0,        0ffffh, DA_DRW
LABEL_DESC_CODE32:      Descriptor       0,SegCode32Len-1, DA_C + DA_32
LABEL_DESC_CODE16:      Descriptor       0,        0ffffh, DA_C
LABEL_DESC_CODE_DEST:   Descriptor       0,SegCodeDestLen-1, DA_C + DA_32
LABEL_DESC_CODE_R3:     Descriptor       0,SegCodeR3Len-1, DA_C + DA_32 + DA_DPL3
LABEL_DESC_DATA:        Descriptor       0,     DataLen-1, DA_DRW
LABEL_DESC_STACK:       Descriptor       0,    TopOfStack, DA_DRWA+DA_32
LABEL_DESC_STACK3:      Descriptor       0,   TopOfStack3, DA_DRWA+DA_32+DA_DPL3
LABEL_DESC_LDT:         Descriptor       0,    LDTLen - 1, DA_LDT
LABEL_DESC_VIDEO:       Descriptor 0B8000h,        0ffffh, DA_DRW+DA_DPL3
;                               选择子          偏移  DCount      属性
LABEL_CALL_GATE_TEST:   Gate SelectorCodeDest,    0,      0, DA_386CGate+DA_DPL0
GdtLen      equ     $ - LABEL_GDT
GdtPtr      dw      GdtLen - 1
            dd      0
SelectorNormal      equ     LABEL_DESC_NORMAL       - LABEL_GDT
SelectorCode32      equ     LABEL_DESC_CODE32       - LABEL_GDT
SelectorCode16      equ     LABEL_DESC_CODE16       - LABEL_GDT
SelectorCodeDest    equ     LABEL_DESC_CODE_DEST    - LABEL_GDT
SelectorCodeR3      equ     LABEL_DESC_CODE_R3      - LABEL_GDT
SelectorData        equ     LABEL_DESC_DATA         - LABEL_GDT
SelectorStack       equ     LABEL_DESC_STACK        - LABEL_GDT
SelectorStack3      equ     LABEL_DESC_STACK3       - LABEL_GDT
SelectorLDT         equ     LABEL_DESC_LDT          - LABEL_GDT
SelectorVideo       equ     LABEL_DESC_VIDEO        - LABEL_GDT
SelectorCallGateTest    equ LABEL_CALL_GATE_TEST    - LABEL_GDT

; data section
[SECTION .data1]
ALIGN   32
[BITS   32]
LABEL_DATA:
SPValueInRealMode       dw      0
; strings
PMMessage:              db      "In_Protect_Mode_now.1235", 0
OffsetPMMessage         equ     PMMessage - $$
StrTest:                db      "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
OffsetStrTest           equ     StrTest - $$
DataLen                 equ     $ - LABEL_DATA

; global stack
[SECTION .gs]
ALIGN   32
[BITS   32]
LABEL_STACK:
    times   512     db      0
TopOfStack      equ     $ - LABEL_STACK

[SECTION .s3]
ALIGN   32
[BITS   32]
LABEL_STACK3:
    times   512     db      0
TopOfStack3     equ     $ - LABEL_STACK3

[SECTION .s16]
[BITS 16]
LABEL_BEGIN:
    mov     ax, cs
    mov     ds, ax
    mov     es, ax
    mov     ss, ax
    mov     sp, 0100h

    mov     [LABEL_GO_BACT_TO_REAL + 3], ax     ; 这里是通过动态的修改下文中的指令的参数 来实现
                                                ; 跳转回实模式的 修改的地方 请搜索 'caution'
                                                ; 指令格式具体请参考原书

    ; init descriptor code32
    xor     eax, eax                            ; 清空eax
    mov     ax, cs                              ; eax = 段基址
    shl     eax, 4                              ; 段基址 * 16
    add     eax, LABEL_SEG_CODE32               ; 加上偏移量
    mov     word [LABEL_DESC_CODE32 + 2], ax    ; 将计算好的32位代码段地址赋给代码段的描述符
    shr     eax, 16
    mov     byte [LABEL_DESC_CODE32 + 4], al
    mov     byte [LABEL_DESC_CODE32 + 7], ah

    ; init descriptor code16
    xor     eax, eax
    mov     ax, cs
    shl     eax, 4
    add     eax, LABEL_SEG_CODE16
    mov     word [LABEL_DESC_CODE16 + 2], ax
    shr     eax, 16
    mov     byte [LABEL_DESC_CODE16 + 4], al
    mov     byte [LABEL_DESC_CODE16 + 7], ah

    ; init descriptor code dest
    xor     eax, eax
    mov     ax, cs
    shl     eax, 4
    add     eax, LABEL_SEG_CODE_DEST
    mov     word [LABEL_DESC_CODE_DEST + 2], ax
    shr     eax, 16
    mov     byte [LABEL_DESC_CODE_DEST + 4], al
    mov     byte [LABEL_DESC_CODE_DEST + 7], ah

    ; init descriptor code ring3
    xor     eax, eax
    mov     ax, cs
    shl     eax, 4
    add     eax, LABEL_SEG_CODE_R3
    mov     word [LABEL_DESC_CODE_R3 + 2], ax
    shr     eax, 16
    mov     byte [LABEL_DESC_CODE_R3 + 4], al
    mov     byte [LABEL_DESC_CODE_R3 + 7], ah

    ; init descriptor data
    xor     eax, eax
    mov     ax, cs
    shl     eax, 4
    add     eax, LABEL_DATA
    mov     word [LABEL_DESC_DATA + 2], ax
    shr     eax, 16
    mov     byte [LABEL_DESC_DATA + 4], al
    mov     byte [LABEL_DESC_DATA + 7], ah

    ; init descriptor stack
    xor     eax, eax
    mov     ax, cs
    shl     eax, 4
    add     eax, LABEL_STACK
    mov     word [LABEL_DESC_STACK + 2], ax
    shr     eax, 16
    mov     byte [LABEL_DESC_STACK + 4], al
    mov     byte [LABEL_DESC_STACK + 7], ah

    ; init descriptor stack ring3
    xor     eax, eax
    mov     ax, cs
    shl     eax, 4
    add     eax, LABEL_STACK3
    mov     word [LABEL_DESC_STACK3 + 2], ax
    shr     eax, 16
    mov     byte [LABEL_DESC_STACK3 + 4], al
    mov     byte [LABEL_DESC_STACK3 + 7], ah

    ; init descriptor ldt
    xor     eax, eax
    mov     ax, cs
    shl     eax, 4
    add     eax, LABEL_LDT
    mov     word [LABEL_DESC_LDT + 2], ax
    shr     eax, 16
    mov     byte [LABEL_DESC_LDT + 4], al
    mov     byte [LABEL_DESC_LDT + 7], ah

    ; init descriptor code in ldt
    xor     eax, eax
    mov     ax, cs
    shl     eax, 4
    add     eax, LABEL_LDT_CODE_A
    mov     word [LABEL_LDT_DESC_CODEA + 2], ax
    shr     eax, 16
    mov     byte [LABEL_LDT_DESC_CODEA + 4], al
    mov     byte [LABEL_LDT_DESC_CODEA + 7], ah

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

LABEL_REAL_ENTRY:
    mov     ax, cs
    mov     ds, ax
    mov     es, ax
    mov     ss, ax
    
    mov     sp, [SPValueInRealMode]

    in      al, 92h
    and     al, 1111101b
    out     92h, al

    sti

    mov     ax, 4c00h           ; return
    int     21h                 ; dos

[SECTION .s16code]
ALIGN   32
[BITS   32]
LABEL_SEG_CODE16:
    ; return real mode
    mov     ax, SelectorNormal
    mov     ds, ax
    mov     es, ax
    mov     fs, ax
    mov     gs, ax
    mov     ss, ax

    mov     eax, cr0
    and     al, 11111110b
    mov     cr0, eax

LABEL_GO_BACT_TO_REAL:
    jmp     0:LABEL_REAL_ENTRY          ; [caution] where the value will be revised by code
Code16Len   equ     $ - LABEL_SEG_CODE16

[SECTION .s32]
[BITS   32]
LABEL_SEG_CODE32:
    mov     ax, SelectorData
    mov     ds, ax
    ; mov     ax, SelectorTest
    mov     es, ax
    mov     ax, SelectorVideo
    mov     gs, ax

    mov     ax, SelectorStack
    mov     ss, ax
    mov     esp, TopOfStack

    ; to show a string
    mov     ah, 0ch
    xor     esi, esi
    xor     edi, edi
    mov     esi, OffsetPMMessage
    mov     edi, (80 * 10 + 0) * 2
    cld
.1:
    lodsb
    test    al, al
    jz      .2
    mov     [gs:edi], ax
    add     edi, 2
    jmp     .1
.2:
    call    DispReturn
    
    ; call    TestRead
    ; call    TestWrite
    ; call    TestRead

    ; call Call-Gate
    ; call    SelectorCallGateTest:0

    ; enter ring3
    ; prepare stack
    push    SelectorStack3
    push    TopOfStack3
    push    SelectorCodeR3
    push    0
    retf

    ; load ldt
    mov     ax, SelectorLDT
    lldt    ax
    
    ; go into ldt code
    jmp     SelectorLDTCodeA:0
;;;;;;;;;;;;;;;;;32bit func
; 读大地址的内存的数据
TestRead:
    xor     esi, esi
    mov     ecx, 8
.loop:
    mov     al, [es:esi]
    call    DispAL
    inc     esi
    loop    .loop

    call    DispReturn

    ret
; 写大地址的内存的数据
TestWrite:
    push    esi
    push    edi
    xor     esi, esi
    xor     edi, edi
    mov     esi, OffsetStrTest
    cld
.1:
    lodsb
    test    al, al
    jz      .2
    mov     [es:edi], al
    inc     edi
    jmp     .1
.2:
    pop     edi
    pop     esi

    ret

; 输出寄存器AL的值
DispAL:
    push    ecx
    push    edx

    mov     ah, 0ch
    mov     dl, al
    shr     al, 4
    mov     ecx, 2
.begin:
    and     al, 01111b
    cmp     al, 9
    ja      .1
    add     al, '0'
    jmp     .2
.1:
    sub     al, 0ah         ; 当值超过了9 就要去添加基于A的值 就和ascii字符转成数字一个意思
    add     al, 'A'
.2:
    mov     [gs:edi], ax
    add     edi, 2

    mov     al, dl
    loop    .begin
    add     edi, 2

    pop     edx
    pop     ecx
    ret

; 输出一个换行
DispReturn:
    push    eax
    push    ebx
    mov     eax, edi
    mov     bl, 160
    div     bl
    and     eax, 0ffh
    inc     eax
    mov     bl, 160
    mul     bl
    mov     edi, eax
    pop     ebx
    pop     eax

    ret
SegCode32Len    equ     $ - LABEL_SEG_CODE32

[SECTION .sdest]
[BITS   32]
LABEL_SEG_CODE_DEST:
    mov     ax, SelectorVideo
    mov     gs, ax

    mov     edi, (80 * 13 + 0) * 2
    mov     ah, 0Ch
    mov     al, 'c'
    mov     [gs:edi], ax

    retf
SegCodeDestLen      equ     $ - LABEL_SEG_CODE_DEST

[SECTION .ring3]
ALIGN   32
[BITS   32]
LABEL_SEG_CODE_R3:
    mov     ax, SelectorVideo
    mov     gs, ax

    mov     edi, (80 * 14 + 0) * 2
    mov     ah, 0Ch
    mov     al, '3'
    mov     [gs:edi], ax

    jmp     $
SegCodeR3Len    equ     $ - LABEL_SEG_CODE_R3

[SECTION .ldt]
ALIGN   32
LABEL_LDT:
;                                       段基址    段界限         属性
LABEL_LDT_DESC_CODEA:       Descriptor      0,  LdtCodeALen-1, DA_C + DA_32

LDTLen          equ     $ - LABEL_LDT

SelectorLDTCodeA     equ     LABEL_LDT_DESC_CODEA    - LABEL_LDT + SA_TIL

[SECTION .la]
ALIGN   32
[BITS   32]
LABEL_LDT_CODE_A:
    mov     ax, SelectorVideo
    mov     gs, ax

    ; 14行
    mov     edi, (80 * 14 + 0) * 2
    mov     ah, 0Ch
    mov     al, 'L'
    mov     [gs:edi], ax

    jmp     SelectorCode16:0
LdtCodeALen     equ     $ - LABEL_LDT_CODE_A