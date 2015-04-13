bits 16

%include "source/memory.h"
%include "source/text.h"

    THEME equ DBLUE << 4 | WHITE

org BOOT
boot:
    jmp short start
    times 3 - ($ - boot) db 0

; We set the whole BPB block to 0s because we will splice in the actual info
; from the disk image we are writing the boot sector to.
bpb:
  .oemIdentifier:
    times 8 db 0
  .bytesPerSector:
    dw 0
  .sectorsPerCluster:
    db 0
  .reservedSectors:
    dw 0
  .fats:
    db 0
  .directoryEntries:
    dw 0
  .totalSectors:
    dw 0
  .mediaDescriptorType:
    db 0
  .sectorsPerFat:
    dw 0
  .sectorsPerTrack:
    dw 0
  .heads:
    dw 0
  .hiddenSectors:
    dd 0
  .largeTotalSectors:
    dd 0
  .drive:
    db 0
  .flags:
    db 0
  .signature:
    db 0
  .volumeId:
    dd 0
  .volumeLabel:
    times 11 db 0
  .systemId:
    times 8 db 0

start:
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
    ; ah = Colors Byte
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

