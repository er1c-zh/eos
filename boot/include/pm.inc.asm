; 描述符类型
DA_32       EQU     4000H
DA_LIMIT_4K EQU     8000H
; DPL
DA_DPL0     EQU     00H
DA_DPL1     EQU     20H
DA_DPL2     EQU     40H
DA_DPL3     EQU     60H

; 存储段描述类型
; D - data
; C - code
DA_DR       EQU     90h         ; 只读数据
DA_DRW      EQU     92h         ; 可读写
DA_DRWA     EQU     93h         ; 已访问可读写
DA_C        EQU     98h         ; 只执行
DA_CR       EQU     9Ah         ; 可执行可读写
DA_CCO      EQU     9Ch         ; 只执行一致代码段
DA_CCOR     EQU     9Eh         ; 可执行可读一致代码段

; 系统段描述类型
DA_LDT      EQU     82h         ; 局部描述符
DA_TaskGate EQU     85h         ; 任务门
DA_386TSS   EQU     89h         ; 可用386任务状态段
DA_386CGate EQU     8Ch         ; 调用门
DA_386IGate EQU     8Eh         ; 中断门
DA_386TGate EQU     8Fh         ; 陷阱门

; 选择子
SA_RPL0     EQU     0
SA_RPL1     EQU     1
SA_RPL2     EQU     2
SA_RPL3     EQU     3

SA_TIG      EQU     0
SA_TIL      EQU     4

; 分页机制使用的常量
PG_P        EQU     1   ; 页存在
PG_RWR      EQU     0   ; R/W 读/执行
PG_RWW      EQU     2   ; R/W 读/写/执行
PG_USS      EQU     0   ; U/S 系统级
PG_USU      EQU     4   ; U/S 用户级

; 宏
; 描述符
%macro Descriptor 3
    dw  %2 & 0FFFFh                         ; 段界限1
    dw  %1 & 0FFFFh                         ; 段基址1
    db (%1 >> 16) & 0FFh                    ; 段基址1
    dw ((%2 >> 8) & 0F00h) | (%3 & 0F0FFh)  ; 各种属性与段界限2
    db (%1 >> 24) & 0FFh                    ; 段基址2
%endmacro

; 门
%macro Gate 4
    dw (%2 & 0FFFFh)                        ; 偏移
    dw %1                                   ; 选择子
    dw (%3 & 1Fh) | ((%4 << 8) & 0FF00h)   ; 两byte的属性
    dw ((%2 >> 16) & 0FFFFh)                ; 偏移
%endmacro
