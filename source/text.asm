hideCursor:
    mov ah, 0x01
    mov cx, 0x2000
    int 0x10
    ret

cls:
    ; ah = Colors Byte
    xor al, al
    xor bx, bx
    mov cx, TEXT_COLS * TEXT_ROWS
  .charLoop:
    mov [es:bx], ax
    times TEXT_CHARSIZE inc bx
    loop .charLoop
    ret
