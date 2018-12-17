;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 寻找并加载loader.bin到内存           ;;
;; 如果加载成功，将控制权交给loader.bin ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
org     07c00h

BaseOfStack     equ 01c00h
%include "load.inc.asm"

    jmp     short LABEL_START
    nop

%include "fat12hdr.inc.asm"

LABEL_START:
    mov     ax, cs
    mov     ds, ax
    mov     es, ax
    mov     ss, ax
    mov     sp, BaseOfStack

    ; clean
    mov     ax, 0600h
    mov     bx, 0700h
    mov     cx, 0
    mov     dx, 0184fh
    int     10h

    mov     dh, 0
    call    DispStr

    xor     ah, ah
    xor     dl, dl
    int     13h

    mov     word [wSectorNo], SectorNoOfRootDir        ; 初始化开始寻找loader.bin的位置
LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
    cmp     word [wRootDirSizeForLoop], 0   ; 检查是否找到尾部
    jz      LABEL_NO_LOADERBIN
    dec     word [wRootDirSizeForLoop]
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
    mov     ax, BaseOfLoader
    mov     es, ax
    mov     bx, OffsetOfLoader
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
