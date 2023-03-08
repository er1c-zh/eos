;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 寻找并加载loader.bin到内存           ;;
;; 如果加载成功，将控制权交给loader.bin ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 此文件的编译产物会作为 MBR和FAT12的保留扇区 写入到生成的镜像中。
; 细节参阅 MBR 和 FAT12 相关的文档。

org     07c00h

BaseOfStack     equ 01c00h
%include "load.inc.asm" ; 加载loader和kernel需要的常量

    ; BIOS探测到扇区结尾的0xAA55后将操作系统的控制权交给接下来的代码
    ; BIOS将这个扇区加载到内存地址 7C00 上
    jmp     short LABEL_START ; FAT12保留扇区 跳转语句，到直接执行的地方
    nop

%include "fat12hdr.inc.asm" ; FAT12的hdr

LABEL_START:
    mov     ax, cs
    mov     ds, ax
    mov     es, ax
    mov     ss, ax
    mov     sp, BaseOfStack

    ; 清屏
    mov     ax, 0600h ; AH=06h scroll up window
    mov     bx, 0700h ; BH 控制颜色
    mov     cx, 0
    mov     dx, 0184fh ; 左上角到右下角全部滚动上去
    int     10h ; BIOS 10h 中断

    mov     dh, 0
    call    DispStr

    xor     ah, ah ; AH=0 重置disk系统
    xor     dl, dl ; DL=0 First Floppy Disk
    int     13h ; Low Level Disk Services

    mov     word [wSectorNo], SectorNoOfRootDir        ; 初始化开始寻找loader.bin的位置
LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
    ;检查是否找到尾部
    cmp     word [wRootDirSizeForLoop], 0   ; 只检查根目录，每次读一个sector
    jz      LABEL_NO_LOADERBIN
    dec     word [wRootDirSizeForLoop] ; 每次读一个sector，减一
    mov     ax, BaseOfLoader
    mov     es, ax
    mov     bx, OffsetOfLoader
    mov     ax, [wSectorNo]
    mov     cl, 1
    call    ReadSector

    mov     si, LoaderFileName
    mov     di, OffsetOfLoader
    cld
    mov     dx, 10h
LABEL_SEARCH_FOR_LOADERBIN:
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
    mov     si, LoaderFileName
    jmp     LABEL_SEARCH_FOR_LOADERBIN

LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
    add     word [wSectorNo], 1
    jmp     LABEL_SEARCH_IN_ROOT_DIR_BEGIN

LABEL_NO_LOADERBIN:
    mov     dh, 2
    call    DispStr
    jmp     $
LABEL_FILENAME_FOUND:
    mov     ax, RootDirSectors
    and     di, 0FFE0h
    add     di, 01Ah
    mov     cx, word [es:di]
    push    cx
    add     cx, ax
    add     cx, DeltaSectorNo
    mov     ax, BaseOfLoader ; 09000h
    mov     es, ax
    mov     bx, OffsetOfLoader ; 0100h
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
    call    DispStr

    jmp     BaseOfLoader:OffsetOfLoader

wRootDirSizeForLoop     dw      RootDirSectors
wSectorNo               dw      0
bOdd                    db      0
LoaderFileName          db      "LOADER  BIN", 0
MsgLen                  equ     9
BootMsg:                db      "Booting  "
Msg1                    db      "Ready.   "
Msg2                    db      "NO LOADER"

; 通过dh的值输出预设的字符串
DispStr:
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

; AX 要读取的扇区号码(从0开始) CL 要读取的扇区数目
; 1.44软盘 两个磁头0、1，每面80个磁道0~79，每个磁道18个扇区1~18
; int 13h ah=02h 读扇区 al 要读的扇区个数
; ch 柱面/磁道号 cl 起始扇区号
; dh 磁头号 dl 驱动器号码 0表示a盘
; 写入 es:bx指向的缓冲区
ReadSector:
    push    bp
    mov     bp, sp
    sub     esp, 2
    mov     byte [bp - 2], cl ; 读取的扇区数
    push    bx
    ; 计算柱面 扇区 磁头
    mov     bl, [BPB_SecPerTrk] ; bl = 每次磁道扇区数
    div     bl ; ah 要读取的扇区在对应的磁道上偏移量 al 要读取的扇区位于的磁道号
    inc     ah
    mov     cl, ah ; 扇区offset：因为ax时从0开始的，所以要加1
    mov     dh, al
    and     dh, 1 ; 磁头 1.44软盘 两个盘面 两个磁头正反编码
    shr     al, 1
    mov     ch, al ; 柱面 一个柱面，正反编码，所以除2
    pop     bx
    mov     dl, [BS_DrvNum] ; 驱动器
.GoOnReading:
    mov     ah, 2 ; 中断13h 读扇区
    mov     al, byte [bp - 2] ; 读取的扇区数
    int     13h
    jc      .GoOnReading

    add     esp, 2
    pop     bp

    ret

GetFATEntry:
    push    es
    push    bx
    push    ax

    mov     ax, BaseOfLoader
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

times       510 - ($ - $$)  db 0
dw          0xaa55
