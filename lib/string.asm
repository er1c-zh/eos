[SECTION .text]
global mem_cpy
global mem_set

; 拷贝内存
; mem_cpy(void* dst, void* src, int size);
; 
mem_cpy:
    push    ebp         ; 储存ebp寄存器
    mov     ebp, esp    ; 保存堆栈指针

    ; 保护现场
    push    esi
    push    edi
    push    ecx

    ; esp       -> esi(old)
    ; esp + 4   -> edi(old)
    ; esp + 8   -> ecx(old)
    ; ebp=esp+12-> ebp(old)
    ; ebp + 4   -> return address
    ; ebp + 8   -> first params dst
    ; ebp + 12  -> second params src
    ; ebp + 16  -> third params bytes to copy
    ; (使用ebp时,默认使用ss作为段基址)
    ; 这段的含义是从堆栈读取三个参数
    mov     edi, [ebp + 8]  ; 最后推入的参数 dst (因为x86架构堆栈从高地址向下增长)
    mov     esi, [ebp + 12] ; 中间推入的参数 src
    mov     ecx, [ebp + 16] ; 最先推入的参数 size

.1:
    cmp     ecx, 0
    jz      .2

    mov     al, [ds:esi]        ; 一次移动一字节
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

; ------------------------------------------------------------------------
; void memset(void* p_dst, char ch, int size);
; ------------------------------------------------------------------------
mem_set:
	push	ebp
	mov	ebp, esp

	push	esi
	push	edi
	push	ecx

	mov	edi, [ebp + 8]	; Destination
	mov	edx, [ebp + 12]	; Char to be putted
	mov	ecx, [ebp + 16]	; Counter
.1:
	cmp	ecx, 0		; 判断计数器
	jz	.2		; 计数器为零时跳出

	mov	byte [edi], dl		; ┓
	inc	edi			; ┛

	dec	ecx		; 计数器减一
	jmp	.1		; 循环
.2:

	pop	ecx
	pop	edi
	pop	esi
	mov	esp, ebp
	pop	ebp

	ret			; 函数结束，返回
; ------------------------------------------------------------------------

