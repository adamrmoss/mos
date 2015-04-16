logo:
    db 0x0f, 0x81, 0xe0, 0x00, 0x7e, 0x00, 0x07, 0xff, 0xc0


drawLogo:
    ; ah = Colors Byte
    xor al, al
    mov cx, TEXT_COLS * TEXT_ROWS
    xor bx, bx
  .clsLoop:
    mov [es:bx], ax
    times TEXT_CHARSIZE inc bx
    loop .clsLoop
    ret
