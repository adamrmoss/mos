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
    mov ax, TEXT >> 4
    mov es, ax
 
    call hideCursor
    mov ah, THEME
    call cls

    ; Spin
    jmp short $

hideCursor:
    mov ah, 0x01
    mov cx, 0x2000
    int 0x10
    ret

cls:
    xor al, al
    mov cx, TEXT_COLS * TEXT_ROWS
    xor bx, bx
  .clsLoop:
    mov [es:bx], ax
    inc bx
    inc bx
    loop .clsLoop
    ret

padding:
    times 510-($-$$) db 0

signature:
    dw 0xaa55

