bits 16

%include "source/memory.asm"
%include "source/text.asm"

    THEME equ DBLUE << 4 | LGREEN

org BOOT
    ; Setup Stack
    mov ax, STACK >> 4
    mov ss, ax
    mov sp, 0xffff

    ; Setup Video
    mov ax, VIDEO >> 4
    mov ds, ax

cls:
    mov ax, THEME << 8
    mov cx, TEXT_COLS * TEXT_ROWS / 2
    xor bx, bx
  .clsLoop:
    mov [ds:bx], ax
    inc bx
    inc bx
    loop .clsLoop
 
    ; Spin
    jmp short $

padding:
    times 510-($-$$) db 0

signature:
    dw 0xaa55

