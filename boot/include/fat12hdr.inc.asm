BS_OEMName          db 'ericzhao'
BPB_BytesPerSec     dw 512
BPB_SecPerClus      db 1
BPB_RsvdSecCnt      dw 1
BPB_NumFATs         db 2
BPB_RootEntCnt      dw 224
BPB_TotSec16        dw 2880
BPB_Media           db 0xF0
BPB_FATSz16         dw 9
BPB_SecPerTrk       dw 18
BPB_NumHeads        dw 2
BPB_HiddSec         dd 0
BPB_TotSec32        dd 0
BS_DrvNum           db 0
BS_Reserved1        db 0
BS_BootSig          db 29h
BS_VolID            dd 0
BS_VolLab           db 'EricOSV0.0.1'
BS_FileSysType      db 'FAT12   '

; 一些预计算的常量
; 生成的软盘镜像的格式
; sector 0 - 启动扇区
; sector 1 - 9 [1, 9] FAT1
; sector 10 -
; sector 0 -
; sector 0 -
FATSz               equ 9 ; 一个FAT的扇区数
RootDirSectors      equ 14 ; FAT限制 根目录记录的大小 14个sector = (224条 * 32(byte per record)) / 512 (byte per sector)
SectorNoOfRootDir   equ 19 ; 1 （保留扇区） + 2 * 9 （FAT表），从0开始编号，所以是19
SectorNoOfFAT1      equ 1 ; 第一个FAT的第一个扇区
DeltaSectorNo       equ 17