; 一些功能性的函数
; 输出寄存器AL的值
DispAL:
    push    ecx
    push    edx
    push    edi

    mov     edi, [dwDispPos]

    mov     ah, 0Fh
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
    sub     al, 0Ah         ; 当值超过了9 就要去添加基于A的值 就和ascii字符转成数字一个意思
    add     al, 'A'
.2:
    mov     [gs:edi], ax
    add     edi, 2

    mov     al, dl
    loop    .begin

    mov     [dwDispPos], edi

    pop     edi
    pop     edx
    pop     ecx

    ret

; 显示一个int
; 要显示的数
DispInt:
    mov     eax, [esp + 4]      ; 因为DispAL只能输出一个8位的数
    shr     eax, 24             ; 所以需要分四次来输出
    call    DispAL

    mov     eax, [esp + 4]
    shr     eax, 16
    call    DispAL

    mov     eax, [esp + 4]
    shr     eax, 8
    call    DispAL

    mov     eax, [esp + 4]
    call    DispAL

    mov     ah, 07h             ; 这里就是输出一个后缀h
    mov     al, 'h'
    push    edi
    mov     edi, [dwDispPos]
    mov     [gs:edi], ax
    add     edi, 4
    mov     [dwDispPos], edi
    pop     edi

    ret

DispStr:
    push    ebp
    mov     ebp, esp
    push    ebx
    push    esi
    push    edi

    mov     esi, [ebp + 8]
    mov     edi, [dwDispPos]
    mov     ah, 0Fh
.1:
    lodsb                       ; mov   al, [esi]
    test    al, al
    jz      .2
    cmp     al, 0Ah             ; 是回车吗？
    jnz     .3
    push    eax                 ; 输出换行
    mov     eax, edi
    mov     bl, 160
    div     bl
    and     eax, 0FFh
    inc     eax
    mov     bl, 160
    mul     bl
    mov     edi, eax
    pop     eax
    jmp     .1
.3:
    mov     [gs:edi], ax        ; 输出普通字符
    add     edi, 2
    jmp     .1
.2:
    mov     [dwDispPos], edi

    pop     edi
    pop     esi
    pop     ebx
    pop     ebp

    ret

DispReturn:
    push    szReturn
    call    DispStr
    add     esp, 4

    ret

MemCpy:
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
