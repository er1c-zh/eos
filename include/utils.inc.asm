%macro hwint_master 1
    push    %1
    call    spurious_irq
    add     esp, 4
    hlt
%endmacro

%macro hwint_slave 1
    push    %1
    call    spurious_irq
    add     esp, 4
    hlt
%endmacro
