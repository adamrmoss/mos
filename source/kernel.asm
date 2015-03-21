bits 32
align 4

extern textEnd
extern dataEnd
extern bssEnd

section .text
global start
global _start
entry:
    jmp start
align 4
multiboot:
    MBALIGN     equ  1<<0                   ; align loaded modules on page boundaries
    MEMINFO     equ  1<<1                   ; provide memory map
    FLAGS       equ  MBALIGN | MEMINFO      ; this is the Multiboot 'flag' field
    MAGIC       equ  0x1BADB002             ; 'magic number' lets bootloader find the header
    CHECKSUM    equ -(MAGIC + FLAGS)        ; checksum of above, to prove we are multiboot
  .header:
    dd MAGIC
    dd FLAGS
    dd CHECKSUM
    dd multiboot.header
    dd entry
    dd dataEnd
    dd bssEnd
    dd entry
start:
_start:
    mov edi, 0xb8000
    mov esi, greeting
    mov ah, 0x0f
  .charLoop:
    lodsb
    stosw
    or al, al
    jnz .charLoop
    hlt
    jmp short $

section .data
align 4
greeting:
    db "Welcome to mos", 0

section .bss
align 4
    common stack 0x1000
    resd 0x1000
