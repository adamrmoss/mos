bits 16

%include "source/memory.h"
%include "source/text.h"

THEME equ DARK_BLUE << 4 | WHITE

org BOOT
boot:
    jmp near start
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
  .rootEntries:
    dw 0
  .totalSectors:
    dw 0
  .mediaDescriptorType:
    db 0
  .sectorsPerFat:
    dw 0
  .sectorsPerTrack:
    dw 0
  .headsPerCylinder:
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

%include "source/text.asm"

resetFloppy:
    mov ah, 0
    mov dl, 0
    int 0x13
    jc resetFloppy
    ret

readSectors:
    ; ax = Starting sector
    ; cx = Number of sectors to read
    ; es:bx => Buffer to read to
  .start:
    mov di, 0x0005
  .sectorLoop:
    push ax
    push bx
    push cx
    call convertLbaToChs                    ; convert starting sector to CHS
    mov ah, 0x02                            ; BIOS read sector
    mov al, 0x01                            ; read one sector
    mov ch, byte [absoluteTrack]            ; track
    mov cl, byte [absoluteSector]           ; sector
    mov dh, byte [absoluteHead]             ; head
    mov dl, byte [bpb.drive]                ; drive
    int 0x13                                ; invoke BIOS
    jnc .success                            ; test for read error
    xor ax, ax                              ; BIOS reset disk
    int 0x13                                ; invoke BIOS
    dec di                                  ; decrement error counter
    pop cx
    pop bx
    pop ax
    jnz .sectorLoop                         ; attempt to read again
    jmp failure
  .success:
    pop cx
    pop bx
    pop ax
    add bx, word [bpb.bytesPerSector]       ; queue next buffer
    inc ax                                  ; queue next sector
    loop .start                             ; read next sector
    ret

print:
    ; ds:si points to a 0-terminated string
    mov ah, 0x0e 
  .startLoop:
    lodsb   
    or  al, al  
    jz  .done
    int 0x10
    jmp .startLoop
  .done:
    ret

convertChsToLba:
    ; ax = clustor
    sub ax, 0x0002                          ; zero base cluster number
    xor cx, cx
    mov cl, byte [bpb.sectorsPerCluster]    ; convert byte to word
    mul cx
    add ax, word [dataSector]               ; base data sector
    ret

convertLbaToChs:
    ; ax = LBA address
    ; absolute sector = (logical sector / sectors per track) + 1
    ; absolute head   = (logical sector / sectors per track) MOD number of heads
    ; absolute track  = logical sector / (sectors per track * number of heads)
    xor dx, dx                              ; prepare dx:ax for operation
    div word [bpb.sectorsPerTrack]          ; calculate
    inc dl                                  ; adjust for sector 0
    mov byte [absoluteSector], dl
    xor dx, dx                              ; prepare dx:ax for operation
    div word [bpb.headsPerCylinder]         ; calculate
    mov byte [absoluteHead], dl
    mov byte [absoluteTrack], al
    ret

absoluteSector:
    db 0x00
absoluteHead:
    db 0x00
absoluteTrack:
    db 0x00
dataSector:
    dw 0x0000
cluster:
    dw 0x0000
kernelFilename:
    db "KERNEL     "

start:
    ; Setup Stack
    mov ax, STACK >> 4
    mov ss, ax
    mov sp, 0xffff

    ; Setup Video
    mov ax, TEXT >> 4
    mov es, ax
 
    mov ah, THEME
    call setColors

    mov si, welcomeMessage
    call print
    mov si, crlfMessage
    call print

loadRoot:
    xor cx, cx
    xor dx, dx
    mov ax, 0x0020              
    mul word [bpb.rootEntries]   
    div word [bpb.bytesPerSector]
    xchg ax, cx

    mov al, [bpb.fats]
    mul word [bpb.sectorsPerFat]
    add ax, word [bpb.reservedSectors]
    mov word [dataSector], ax
    add word [dataSector], cx
    
    mov bx, BOOT_FAT >> 4
    mov es, bx
    xor bx, bx
    call readSectors

findKernel:
    mov cx, word [bpb.rootEntries]
    xor di, di
  .loop:
    push cx
    mov cx, 0x000b   
    mov si, kernelFilename
    push di
    rep cmpsb
    pop di
    je loadFat
    pop cx
    add di, 0x0020
    loop .loop
    jmp failure

loadFat:
    mov si, crlfMessage
    call print
    mov dx, word [di + 0x001A]
    mov word [cluster], dx
    xor ax, ax
    mov al, byte [bpb.fats]
    mul word [bpb.sectorsPerFat]   
    mov cx, ax
    mov ax, word [bpb.reservedSectors]
    xor bx, bx
    call readSectors
    mov si, crlfMessage
    call print
    mov ax, KERNEL >> 4
    mov es, ax     
    mov bx, 0x0000 
    push bx

loadKernel:
    mov ax, word [cluster]             
    pop bx                             
    call convertChsToLba                     
    xor cx, cx
    mov cl, byte [bpb.sectorsPerCluster]
    call readSectors
    push bx
    mov ax, word [cluster]
    mov cx, ax            
    mov dx, ax            
    shr dx, 0x0001        
    add cx, dx            
    mov bx, 0x0200        
    add bx, cx            
    mov dx, word [bx]     
    test ax, 0x0001
    jnz .oddCluster
  .evenCluster:
    and dx, 0x0fff
    jmp .done
  .oddCluster:
    shr dx, 0x0004
  .done:
    mov word [cluster], dx
    cmp dx, 0x0ff0        
    jb loadKernel

done:
    mov si, crlfMessage
    call print
    push word KERNEL >> 4
    push word 0x0000
    retf

failure:
    mov si, failureMessage
    call print
    mov ah, 0x00
    ; Wait for keypress
    int 0x16
    ; Warm boot
    int 0x19          

welcomeMessage:
    db "Welcome to MOS", 0x00
loadingKernelMessage:
    db "Loading", 0x00
progressMessage:
    db ".", 0x00
failureMessage:
    db "Failed", 0x00
crlfMessage:
    db 0x0d, 0x0a, 0x00

padding:
    times 510 - ($ - $$) db 0

signature:
    dw 0xaa55

