%include    "pm.inc.asm"
%ifdef _BUILD_COM_
    org     0100h 
%else
    org     07c00h
%endif
    jmp     LABEL_BEGIN

PDEBase             equ     200000h
PTEBase             equ     201000h

[SECTION .gdt]
;                                   段基址      段界限      属性
LABEL_GDT:              Descriptor       0,             0,      0
LABEL_DESC_NORMAL:      Descriptor       0,        0ffffh, DA_DRW
LABEL_DESC_PDE:         Descriptor PDEBase,          4095, DA_DRW
LABEL_DESC_PTE:         Descriptor PTEBase,          1023, DA_DRW|DA_LIMIT_4K
LABEL_DESC_CODE32:      Descriptor       0,SegCode32Len-1, DA_C + DA_32
LABEL_DESC_CODE16:      Descriptor       0,        0ffffh, DA_C
LABEL_DESC_DATA:        Descriptor       0,     DataLen-1, DA_DRW
LABEL_DESC_STACK:       Descriptor       0,    TopOfStack, DA_DRWA+DA_32
LABEL_DESC_VIDEO:       Descriptor 0B8000h,        0ffffh, DA_DRW
GdtLen      equ     $ - LABEL_GDT
GdtPtr      dw      GdtLen - 1
            dd      0
SelectorNormal      equ     LABEL_DESC_NORMAL       - LABEL_GDT
SelectorPDE         equ     LABEL_DESC_PDE          - LABEL_GDT
SelectorPTE         equ     LABEL_DESC_PTE          - LABEL_GDT
SelectorCode32      equ     LABEL_DESC_CODE32       - LABEL_GDT
SelectorCode16      equ     LABEL_DESC_CODE16       - LABEL_GDT
SelectorData        equ     LABEL_DESC_DATA         - LABEL_GDT
SelectorStack       equ     LABEL_DESC_STACK        - LABEL_GDT
SelectorVideo       equ     LABEL_DESC_VIDEO        - LABEL_GDT

; data section
[SECTION .data1]
ALIGN   32
[BITS   32]
LABEL_DATA:
; 在实模式中使用
;   字符串
_szPMMessage:           db      "In_Protect_Mode_now.1111", 0Ah, 0Ah, 0     ; 0Ah - 回车:
_szMemCheckTitle:       db      "BaseAddrL BaseAddrH LengthLow LengthHeight Type", 0Ah, 0
_szRAMSize:             db      "RAM Size:", 0
_szReturn:              db      0Ah, 0      ; 回车
; 变量:
_wSPValueInRealMode     dw      0
_dwMCRNumber:           dd      0   ; 检查内存信息的结果个数 todo check is right
_dwDispPos:             dd      (80 * 6 + 0) * 2    ; 输出的位置
_dwMemSize:             dd      0
_ARDStruct:
    _dwBaseAddrLow:     dd      0
    _dwBaseAddrHigh:    dd      0
    _dwLengthLow:       dd      0
    _dwLengthHigh:      dd      0
    _dwType:            dd      0
_MemCheckBuffer:        times   256     db      0
; 在保护模式中使用
SPValueInRealMode       equ     _wSPValueInRealMode - $$
szPMMessage             equ     _szPMMessage        - $$
szMemCheckTitle         equ     _szMemCheckTitle    - $$
szRAMSize               equ     _szRAMSize          - $$
szReturn                equ     _szReturn           - $$
dwMCRNumber             equ     _dwMCRNumber        - $$
dwDispPos               equ     _dwDispPos          - $$
dwMemSize               equ     _dwMemSize          - $$
ARDStruct               equ     _ARDStruct          - $$
    dwBaseAddrLow       equ     _dwBaseAddrLow      - $$
    dwBaseAddrHigh      equ     _dwBaseAddrHigh     - $$
    dwLengthLow         equ     _dwLengthLow        - $$
    dwLengthHigh        equ     _dwLengthHigh       - $$
    dwType              equ     _dwType             - $$
MemCheckBuffer          equ     _MemCheckBuffer     - $$
DataLen                 equ     $ - LABEL_DATA

; global stack
[SECTION .gs]
ALIGN   32
[BITS   32]
LABEL_STACK:
    times   512     db      0
TopOfStack      equ     $ - LABEL_STACK

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
    mov     [_wSPValueInRealMode], sp

    ; 获得内存数量
    mov     ebx, 0
    mov     di, _MemCheckBuffer
.loop:
    mov     eax, 0E820h
    mov     ecx, 20
    mov     edx, 0534D4150h
    int     15h
    jc      LABEL_MEM_CHECK_FAIL
    add     di, 20
    inc     dword [_dwMCRNumber]
    cmp     ebx, 0
    jne     .loop
    jmp     LABEL_MEM_CHECK_OK
LABEL_MEM_CHECK_FAIL:
    mov     dword [_dwMCRNumber], 0
LABEL_MEM_CHECK_OK:

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
[BITS   16]
LABEL_SEG_CODE16:
    ; return real mode
    mov     ax, SelectorNormal
    mov     ds, ax
    mov     es, ax
    mov     fs, ax
    mov     gs, ax
    mov     ss, ax

    mov     eax, cr0
    and     eax, 7FFFFFFEh		; PE=0, PG=0
    mov     cr0, eax

LABEL_GO_BACT_TO_REAL:
    ; 这里的段地址0将会被上文中的代码修改掉 指向应有的段地址
    jmp     0:LABEL_REAL_ENTRY          ; [caution] where the value will be revised by code
Code16Len   equ     $ - LABEL_SEG_CODE16

[SECTION .s32]
[BITS   32]
LABEL_SEG_CODE32:
    call    SetupPaging

    mov     ax, SelectorData
    mov     ds, ax
    mov     ax, SelectorData
    mov     es, ax
    mov     ax, SelectorVideo
    mov     gs, ax

    mov     ax, SelectorStack
    mov     ss, ax
    mov     esp, TopOfStack

    push    szPMMessage
    call    DispStr
    call    DispReturn

    call    DispMemSize

    jmp     SelectorCode16:0

; 用于启动分页机制
SetupPaging:
    mov     ax, SelectorPDE
    mov     es, ax
    mov     ecx, 1024
    xor     edi, edi                        ; es:edi 指向PDE的开头
    xor     eax, eax
    mov     eax, PTEBase | PG_P | PG_USU | PG_RWW     ; 对应页表基址 | 存在 | 用户级别 | 可读可写
.1:
    ; 初始化PDE
    stosd                                   ; mov [es:edi], eax; edi = edi + 4
    add     eax, 4096                       ; 每次循环页目录表记录的页表地址增加4096 (4KB)
    ; 循环ecx 1024次
    loop    .1
    ; 初始化所有的页表
    mov     ax, SelectorPTE
    mov     es, ax
    mov     ecx, 1024 * 1024                ; 初始化1024 * 1024个页表
    xor     edi, edi
    xor     eax, eax
    mov     eax, PG_P | PG_USU | PG_RWW     ; 存在 | 用户级别 | 可读可写
.2:
    stosd
    add     eax, 4096                       ; 每次循环 页表大小为4096（4KB）
    loop    .2

    mov     eax, PDEBase                    ; 加载页目录表
    mov     cr3, eax
    mov     eax, cr0
    or      eax, 8000000h
    mov     cr0, eax
    jmp     short .3
.3:
    nop

    ret

DispMemSize:
    push    esi
    push    edi
    push    ecx

    mov     esi, MemCheckBuffer
    mov     ecx, [dwMCRNumber]

.loop:
    mov     edx, 5
    mov     edi, ARDStruct
.1:
    push    dword [esi]
    call    DispInt
    pop     eax
    stosd
    add     esi, 4
    dec     edx
    cmp     edx, 0
    jnz     .1
    call    DispReturn
    cmp     dword [dwType], 1
    jne     .2
    mov     eax, [dwBaseAddrLow]
    add     eax, [dwLengthLow]
    cmp     eax, [dwMemSize]
    jb      .2
    mov     [dwMemSize], eax
.2:
    loop    .loop

    call    DispReturn
    push    szRAMSize
    call    DispStr
    add     esp, 4

    push    dword [dwMemSize]
    call    DispInt
    add     esp, 4

    pop     ecx
    pop     edi
    pop     esi

    ret

%include "lib.inc.asm"
SegCode32Len    equ     $ - LABEL_SEG_CODE32