bits 16

%include "memory.asm"
%include "text.asm"

    THEME equ DBLUE << 4 | LGREEN

org BOOT
    xor ax, ax
    mov ds, ax

    mov ax, STACK >> 4
    mov ss, ax
    mov sp, 0xffff  
 
    jmp short $

padding:
    times 510-($-$$) db 0

signature:
    dw 0xaa55

