bits 32

    TEXT_COLS    equ 80
    TEXT_ROWS    equ 80

org 0x00100000
code:
  .multiboot:
    MBALIGN      equ  1<<0
    MEMINFO      equ  1<<1
    AOUT_KLUDGE  equ  1<<16

    FLAGS        equ  MBALIGN | MEMINFO | AOUT_KLUDGE
    MAGIC        equ  0x1badb002
    CHECKSUM     equ -(MAGIC + FLAGS)
    align 4
    dd MAGIC
    dd FLAGS
    dd CHECKSUM
    dd code.multiboot
    dd code
    dd data.end
    dd stack.end
    dd code.entry
  .entry:
    mov ebx, 0xb8000
    xor eax, eax
  .clsLoop:
    mov ecx, TEXT_COLS * TEXT_ROWS / 2
    mov dword [ebx], eax
    add ebx, 4
    loop .clsLoop

  .showGreeting:
    mov edi, 0xb8000
    mov esi, data.greeting
    mov ah, 0x0f
  .charLoop:
    lodsb
    stosw
    or al, al
    jnz .charLoop
    hlt
    jmp short $
    align 4
 .end:

data:
  .greeting:
    db "Welcome to mos", 0
    align 4
 .end:

stack:
    times 0x1000 dd 0
  .end:
