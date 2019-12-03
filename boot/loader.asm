;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 加载器
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
org 0100h

    jmp     LABEL_START

%include    "fat12hdr.inc.asm"
%include    "load.inc.asm"
%include    "pm.inc.asm"
; GDT
;                                   段基址      段界限      属性
LABEL_GDT:              Descriptor       0,             0,      0
LABEL_DESC_FLAT_C:      Descriptor       0,       0fffffh, DA_CR|DA_32|DA_LIMIT_4K
LABEL_DESC_FLAT_RW:     Descriptor       0,       0fffffh, DA_DRW|DA_32|DA_LIMIT_4K
LABEL_DESC_VIDEO:       Descriptor 0B8000h,       0fffffh, DA_DRW|DA_DPL3

GdtLen      equ $ - LABEL_GDT
GdtPtr      dw  GdtLen - 1
            dd  BaseOfLoaderPhyAddr + LABEL_GDT

SelectorFlatC       equ     LABEL_DESC_FLAT_C   - LABEL_GDT
SelectorFlatRW      equ     LABEL_DESC_FLAT_RW  - LABEL_GDT
SelectorVideo       equ     LABEL_DESC_VIDEO    - LABEL_GDT

BaseOfStack     equ     0100h
PDEBase         equ     100000h
PTEBase         equ     101000h

LABEL_START:
    mov     ax, cs
    mov     ds, ax
    mov     es, ax
    mov     ss, ax
    mov     sp, BaseOfStack

    mov     dh, 0
    call    DispStrR ; 通过dh来输出特定的字符串

    ; 获得内存数量
    mov     ebx, 0
    mov     di, _MemCheckBuffer
.loop:
    mov     eax, 0E820h
    mov     ecx, 20
    mov     edx, 0534D4150h
    int     15h ; 系统调用，读取内存信息
    jc      LABEL_MEM_CHECK_FAIL
    add     di, 20
    inc     dword [_dwMCRNumber] ; 存储MCR的个数
    cmp     ebx, 0
    jne     .loop
    jmp     LABEL_MEM_CHECK_OK
LABEL_MEM_CHECK_FAIL:
    mov     dword [_dwMCRNumber], 0 ; 内存检查失败
LABEL_MEM_CHECK_OK:

    ; 开始加载kernel
    mov     word [wSectorNo], SectorNoOfRootDir     ; 初始化开始寻找kernel.bin的位置
    xor     ah, ah
    xor     dl, dl
    int     13h
LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
    cmp     word [wRootDirSizeForLoop], 0   ; 检查是否找到尾部
    jz      LABEL_NO_KERNELBIN              ; 如果到达尾部,表明没有kernel
    dec     word [wRootDirSizeForLoop]
    mov     ax, BaseOfKernel
    mov     es, ax
    mov     bx, OffsetOfKernel
    mov     ax, [wSectorNo]
    mov     cl, 1
    call    ReadSector

    mov     si, KernelFileName
    mov     di, OffsetOfKernel
    cld
    mov     dx, 10h
LABEL_SEARCH_FOR_KERNELBIN:
    cmp     dx, 0
    jz      LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR
    dec     dx
    mov     cx, 11
LABEL_CMP_FILEANME:
    cmp     cx, 0
    jz      LABEL_FILENAME_FOUND
    dec     cx
    lodsb
    cmp     al, byte [es:di]
    jz      LABEL_GO_ON
    jmp     LABEL_DIFFERENT

LABEL_GO_ON:
    inc     di
    jmp     LABEL_CMP_FILEANME

LABEL_DIFFERENT:
    and     di, 0FFE0h
    add     di, 20h
    mov     si, KernelFileName
    jmp     LABEL_SEARCH_FOR_KERNELBIN

LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
    add     word [wSectorNo], 1
    jmp     LABEL_SEARCH_IN_ROOT_DIR_BEGIN

LABEL_NO_KERNELBIN:
    mov     dh, 2
    call    DispStrR
    jmp     $
LABEL_FILENAME_FOUND:
    mov     ax, RootDirSectors
    and     di, 0FFF0h

    push    eax
    mov     eax, [es:di + 01Ch]
    mov     dword [dwKernelSize], eax   ; save size fo kernel
    pop     eax

    add     di, 01Ah
    mov     cx, word [es:di]
    push    cx
    add     cx, ax
    add     cx, DeltaSectorNo
    mov     ax, BaseOfKernel
    mov     es, ax
    mov     bx, OffsetOfKernel
    mov     ax, cx

LABEL_GOON_LOADING_FILE:
    push    ax
    push    bx
    mov     ah, 0Eh
    mov     al, '.'
    mov     bl, 0Fh
    int     10h
    pop     bx
    pop     ax

    mov     cl, 1
    call    ReadSector
    pop     ax
    call    GetFATEntry
    cmp     ax, 0FFFh
    jz      LABEL_FILE_LOADED
    push    ax
    mov     dx, RootDirSectors
    add     ax, dx
    add     ax, DeltaSectorNo
    add     bx, [BPB_BytesPerSec]
    jmp     LABEL_GOON_LOADING_FILE
LABEL_FILE_LOADED:
    mov     dh, 1
    call    DispStrR ; 加载kernel成功之后显示特定提示信息

    lgdt    [GdtPtr] ; 加载gdt

    cli	; 关中断

    in      al, 92h
    or      al, 00000010b
    out     92h, al

    ; 开启保护模式
    mov     eax, cr0
    or      eax, 1
    mov     cr0, eax

    jmp     dword SelectorFlatC:(BaseOfLoaderPhyAddr+LABEL_PM_START)

wRootDirSizeForLoop     dw      RootDirSectors
wSectorNo               dw      0
dwKernelSize            dw      0
bOdd                    db      0
KernelFileName          db      "KERNEL  BIN", 0
MsgLen                  equ     9
BootMsg:                db      "Booting  "
Msg1                    db      "Ready.   "
Msg2                    db      "NO KERNEL"

DispStrR:
    mov     ax, MsgLen
    mul     dh
    add     ax, BootMsg
    mov     bp, ax
    mov     ax, ds
    mov     es, ax
    mov     cx, MsgLen
    mov     ax, 01301h
    mov     bx, 000ch
    mov     dl, 0
    int     10h
    ret

ReadSector:
    push    bp
    mov     bp, sp
    sub     esp, 2
    mov     byte [bp - 2], cl
    push    bx
    mov     bl, [BPB_SecPerTrk]
    div     bl
    inc     ah
    mov     cl, ah
    mov     dh, al
    shr     al, 1
    mov     ch, al
    and     dh, 1
    pop     bx
    mov     dl, [BS_DrvNum]
.GoOnReading:
    mov     ah, 2
    mov     al, byte [bp - 2]
    int     13h
    jc      .GoOnReading

    add     esp, 2
    pop     bp

    ret

GetFATEntry:
    push    es
    push    bx
    push    ax

    mov     ax, BaseOfKernel
    sub     ax, 0100h
    mov     es, ax
    pop     ax

    mov     byte [bOdd], 0
    mov     bx, 3
    mul     bx
    mov     bx, 2
    div     bx
    cmp     dx, 0
    jz      LABEL_EVEN
    mov     byte [bOdd], 1
LABEL_EVEN:
    xor     dx, dx
    mov     bx, [BPB_BytesPerSec]
    div     bx
    push    dx
    mov     bx, 0
    add     ax, SectorNoOfFAT1
    mov     cl, 2
    call    ReadSector

    pop     dx
    add     bx, dx
    mov     ax, [es:bx]
    cmp     byte [bOdd], 1
    jnz     LABEL_EVEN_2
    shr     ax, 4
LABEL_EVEN_2:
    and     ax, 0FFFh

LABEL_GET_FAT_ENTRY_OK:

    pop     bx
    pop     es

    ret

[SECTION    .s32]
ALIGN   32
[BITS   32]
LABEL_PM_START:
    mov     ax, SelectorFlatRW
    mov     ds, ax
    mov     es, ax
    mov     fs, ax
    mov     ss, ax
    mov     esp, TopOfStack
    mov     ax, SelectorVideo
    mov     gs, ax
    
    push    szMemCheckTitle
    call    DispStr
    add     esp, 4

    call    DispMemSize ; 输出内存信息
    call    SetupPaging ; 开启分页

    call    InitKernel

    jmp     SelectorFlatC:KernelEntryPointPhyAddr

; 用于启动分页机制
SetupPaging:
    ; 计算需要初始化多少个页目录记录(PDE)和页表(Page Table)
    ; 一条页表记录4Byte指向一个页4KB,一个页表4KB共有1024个页表记录
    ; 4M == 1024 * 4KB == 一个页表能表示的内存的大小
    xor     edx, edx
    mov     eax, [dwMemSize]                ; dwMemSize 内存有多少字节
    mov     ebx, 400000h                    ; 4MB
    div     ebx
    mov     ecx, eax                        ; eax 是需要的页表个数，也是页目录记录数目
    test    edx, edx                        ; 如果有余数,页表个数要增加一个
    jz     .no_remainder
    inc     ecx
.no_remainder:
    push    ecx                             ; 将页表数记录下来

    mov     ax, SelectorFlatRW
    mov     es, ax
    mov     edi, PDEBase                    ; es:edi 指向PDE的开头
    xor     eax, eax
    mov     eax, PTEBase | PG_P | PG_USU | PG_RWW       ; 对应页表基址 | 存在 | 用户级别 | 可读可写
.1:
    ; 初始化PDE
    stosd                                   ; mov [es:edi], eax; edi = edi + 4
    add     eax, 4096                       ; 每次循环页目录表记录的页表地址增加4096 (4KB)
    ; 循环 内存大小/4MB次
    loop    .1

    ; 初始化所有的页表
    pop     eax                             ; 取出保存的页表数
    mov     ebx, 1024                       ; 一个页表1024个记录
    mul     ebx
    mov     ecx, eax                        ; ecx == 多少个PTE
    mov     edi, PTEBase
    xor     eax, eax
    mov     eax, PG_P | PG_USU | PG_RWW     ; PTE 存在 | 用户级别 | 可读可写
.2:
    stosd
    add     eax, 4096                       ; 每次循环 PTE基地址增加4096（4KB）
    loop    .2                              ; 这里假定,没有特别的映射关系,单纯的线性映射

    ; 开启分页机制
    mov     eax, PDEBase                    ; 加载页目录表到cr3
    mov     cr3, eax
    mov     eax, cr0                        ; cr0置位PG = 1 开启分页
    or      eax, 80000000h
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

    push    szRAMUnits
    call    DispStr
    add     esp, 4

    pop     ecx
    pop     edi
    pop     esi

    ret

InitKernel:
    xor     esi, esi
    mov     cx, word [BaseOfKernelPhyAddr + 2CH]    ; e_phnum(program-header-number)
    movzx   ecx, cx
    mov     esi, [BaseOfKernelPhyAddr + 1Ch]        ; 将e_phoff(program header table在kernel.bin中的偏移量)读入esi
    add     esi, BaseOfKernelPhyAddr                ; 加上kernel.bin的开头地址
.Begin:
    mov     eax, [esi + 0]
    cmp     eax, 0                                  ; 比较了pht中第一个programm-header的p_type
    jz      .NoAction
    push    dword [esi + 010h]                      ; p_filesz (cnt)
    mov     eax, [esi + 04h]                        ; p_offset
    add     eax, BaseOfKernelPhyAddr                ; p_offset + kernel.addr
    push    eax                                     ; (src)
    push    dword [esi + 08h]                       ; p_vaddr 虚拟地址 (dst)
    call    MemCpy
    add     esp, 12
.NoAction:
    add     esi, 020h                               ; 指向下一个programm-header
    dec     ecx
    jnz     .Begin

    ret

%include "lib.inc.asm"

; data section
[SECTION .data1]
ALIGN   32
[BITS   32]
LABEL_DATA:
; 在实模式中使用的label
;   字符串
_szMemCheckTitle:       db      "BaseAddrL BaseAddrH LengthLow LengthHigh Type", 0Ah, 0
_szRAMSize              db      "RAM Size:", 0
_szRAMUnits             db      " bytes", 0
_szReturn               db      0Ah, 0      ; 回车
; 变量:
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
; 在保护模式中使用的label 需要用选择子来访问
szMemCheckTitle         equ     BaseOfLoaderPhyAddr + _szMemCheckTitle
szRAMSize               equ     BaseOfLoaderPhyAddr + _szRAMSize
szRAMUnits              equ     BaseOfLoaderPhyAddr + _szRAMUnits
szReturn                equ     BaseOfLoaderPhyAddr + _szReturn
dwMCRNumber             equ     BaseOfLoaderPhyAddr + _dwMCRNumber
dwDispPos               equ     BaseOfLoaderPhyAddr + _dwDispPos
dwMemSize               equ     BaseOfLoaderPhyAddr + _dwMemSize
ARDStruct               equ     BaseOfLoaderPhyAddr + _ARDStruct
    dwBaseAddrLow       equ     BaseOfLoaderPhyAddr + _dwBaseAddrLow
    dwBaseAddrHigh      equ     BaseOfLoaderPhyAddr + _dwBaseAddrHigh
    dwLengthLow         equ     BaseOfLoaderPhyAddr + _dwLengthLow
    dwLengthHigh        equ     BaseOfLoaderPhyAddr + _dwLengthHigh
    dwType              equ     BaseOfLoaderPhyAddr + _dwType
MemCheckBuffer          equ     BaseOfLoaderPhyAddr + _MemCheckBuffer
DataLen                 equ     $ - LABEL_DATA

    times   1024    db      0
TopOfStack      equ     BaseOfLoaderPhyAddr + $
