section .text
bits 32
align 4
global start
global _start
entry:
  jmp start
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
  dd stackBottom
  dd entry
start:
_start:
  mov esp, stackTop

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
greeting:
  db "Welcome to mos", 0
dataEnd:

; 16 KB Stack
section .bss
bits 32
align 4
stackBottom:
  times 0x1000 resd 0
stackTop:
