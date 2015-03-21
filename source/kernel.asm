; Declare constants used for creating a multiboot header.
MBALIGN     equ  1<<0                   ; align loaded modules on page boundaries
MEMINFO     equ  1<<1                   ; provide memory map
FLAGS       equ  MBALIGN | MEMINFO      ; this is the Multiboot 'flag' field
MAGIC       equ  0x1BADB002             ; 'magic number' lets bootloader find the header
CHECKSUM    equ -(MAGIC + FLAGS)        ; checksum of above, to prove we are multiboot
 
; Multiboot Header
section .multiboot
align 4
  dd MAGIC
  dd FLAGS
  dd CHECKSUM
 
; 16 KB Stack
section .bootstrapStack
align 4
stackBottom:
  times 0x4000 db 0
stackTop:
 
section .text
global _start
_start:
  mov esp, stackTop
 
  cli
.hang:
  hlt
  jmp .hang

