[SECTION .text]
global mem_cpy

; 拷贝内存
; mem_cpy(void* dst, void* src, int size);
mem_cpy:
    push    ebp         ; 储存ebp寄存器
    mov     ebp, esp    ; 保存堆栈指针

    ; 保护现场
    push    esi
    push    edi
    push    ecx

    ; (使用ebp时,默认使用ss作为段基址)
    ; 这段的含义是从堆栈读取三个参数
    mov     edi, [ebp + 8]  ; 最后推入的参数 dst (因为x86架构堆栈从高地址向下增长)
    mov     esi, [ebp + 12] ; 中间推入的参数 src
    mov     ecx, [ebp + 16] ; 最先推入的参数 cnt

.1:
    cmp     ecx, 0
    jz      .2

    mov     al, [ds:esi]        ; 一次移动8位
    inc     esi
    mov     byte [es:edi], al
    inc     edi

    dec     ecx
    jmp     .1
.2:
    mov     eax, [ebp + 8]

    ; 恢复现场
    pop     ecx
    pop     edi
    pop     esi
    mov     esp, ebp
    pop     ebp

    ret
