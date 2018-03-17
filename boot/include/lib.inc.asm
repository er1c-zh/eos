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