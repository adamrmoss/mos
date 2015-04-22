hideCursor:
    mov ah, 0x01
    mov cx, 0x2000
    int 0x10
    ret

setColors:
    pusha
    ; ah = Colors Byte
    mov bx, 0x0001
    mov cx, TEXT_COLS * TEXT_ROWS
  .charLoop:
    mov [es:bx], ah
    times TEXT_CHARSIZE inc bx
    loop .charLoop
    popa
    ret

cls:
    pusha
    ; ah = Colors Byte
    xor al, al
    xor bx, bx
    mov cx, TEXT_COLS * TEXT_ROWS
  .charLoop:
    mov [es:bx], ax
    times TEXT_CHARSIZE inc bx
    loop .charLoop
    popa
    ret
