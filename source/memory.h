; IDT and BDA always go at the beginning of memory
IDT     equ 0x00000000
BDA     equ 0x00000400

; We will setup our 16-bit stack to go right afterwards
STACK   equ 0x00000500

; Our new stack will contain the area where BIOS loads the boot sector: possible,
; eventually overwriting it
BOOT    equ 0x00007c00

; We will load our kernel right after the stack.
KERNEL  equ 0x00010500

; Direct access to video memory
VIDEO   equ 0x000a0000

; Start of text mode video memory
TEXT    equ 0x000b8000
