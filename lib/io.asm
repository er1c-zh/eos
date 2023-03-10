extern  disp_pos
extern  mem_set

[SECTION .text]

global  disp_str
global  disp_color_str
global  clear

global  in_byte
global  out_byte

; ===========================================
; void clear();
; ===========================================
clear:
    push eax
    push edi

    ; 80 * 25 * 2 = 4000 byte
    xor  eax, eax
    xor  edi, edi
clear_loop:
    cmp  eax, 4000
    je   clear_done
    mov  byte [gs:edi], 0
    inc  edi 
    inc  eax
    jmp  clear_loop

clear_done:
    mov  dword [disp_pos], 0

    pop  edi
    pop  eax
    ret

; ===========================================
; void disp_str(char* str)
; ===========================================
disp_str:
    push    ebp
    mov     ebp, esp

    mov     esi, [ebp + 8]
    mov     edi, [disp_pos]
    mov     ah, 0Fh     ; 黑底白字
.1:
    lodsb
    test    al, al
    jz      .2
    cmp     al, 0Ah
    jnz     .3
    push    eax
    push    ebx             ; fix 如果不保护ebx 就会输出了乱码 why?
    mov     eax, edi
    mov     bl, 160
    div     bl
    and     eax, 0FFh
    inc     eax
    mov     bl, 160
    mul     bl
    mov     edi, eax
    pop     ebx
    pop     eax
    jmp     .1
.3:
    mov     [gs:edi], ax
    add     edi, 2
    jmp     .1
.2:
    mov     [disp_pos], edi

    pop     ebp
    ret

; ===========================================
; void disp_color_str(char* str, int color)
; ===========================================
disp_color_str:
    push    ebp
    mov     ebp, esp

    mov     esi, [ebp + 8]
    mov     edi, [disp_pos]
    mov     ah, [ebp + 12]
.1:
    lodsb
    test    al, al
    jz      .2
    cmp     al, 0Ah
    jnz     .3
    push    eax
    push    ebx
    mov     eax, edi
    mov     bl, 160
    div     bl
    and     eax, 0FFh
    inc     eax
    mov     bl, 160
    mul     bl
    mov     edi, eax
    pop     ebx
    pop     eax
    jmp     .1
.3:
    mov     [gs:di], ax
    add     edi, 2
    jmp     .1
.2:
    mov     [disp_pos], edi

    pop     ebp
    ret

; ===========================================
; u8 in_byte(u16 port);
; ===========================================
in_byte:
    mov     edx, [esp + 4]      ; io port
    xor     eax, eax
    in      al, dx
    nop
    nop
    
    ret

; ===========================================
; void in_byte(u16 port, u8 val);
; ===========================================
out_byte:
    mov     edx, [esp + 4]      ; io port
    mov     al, [esp + 4 + 4]   ; val to out
    out     dx, al
    nop
    nop

    ret

