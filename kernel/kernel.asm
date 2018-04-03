[section .text]

global  _start

_start:
    mov     ax, 0Fh
    mov     al, 'K'
    mov     [gs:((80 * 1 + 39) * 2)], ax
    jmp     $