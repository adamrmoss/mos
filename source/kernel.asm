bits 32
    VIDEO_BASE equ 0xb8000
    TEXT_COLS  equ 80
    TEXT_ROWS  equ 25

    BLACK    equ 0x0
    DBLUE    equ 0x1
    DGREEN   equ 0x2
    DCYAN    equ 0x3
    DRED     equ 0x4
    DMAGENTA equ 0x5
    BROWN    equ 0x6
    LGREY    equ 0x7
    DGREY    equ 0x8
    LBLUE    equ 0x9
    LGREEN   equ 0xa
    LCYAN    equ 0xb
    LRED     equ 0xc
    LMAGENTA equ 0xd
    YELLOW   equ 0xe
    WHITE    equ 0xf

    THEME equ DBLUE << 4 | LGREEN

org 0x00100000
code:
  .multiboot:
    MBALIGN      equ  1<<0
    MEMINFO      equ  1<<1
    AOUT_KLUDGE  equ  1<<16

    FLAGS     equ  MBALIGN | MEMINFO | AOUT_KLUDGE
    MAGIC     equ  0x1badb002
    CHECKSUM  equ -(MAGIC + FLAGS)

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
    mov esp, stack.end - 4

 .cls:
    mov ebx, VIDEO_BASE
    push ebx
    pop ebx
    mov eax, THEME << 24 | THEME << 8
  .clsLoop:
    mov ecx, TEXT_COLS * TEXT_ROWS / 2
    mov dword [ebx], eax
    add ebx, 4
    loop .clsLoop

  .showGreeting:
    GREETING_OFFSET equ TEXT_ROWS * TEXT_COLS - (data.greetingEnd - data.greeting - 1)
    mov edi, VIDEO_BASE + GREETING_OFFSET
    mov esi, data.greeting
    mov ah, THEME
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
    db "welcome to mos", 0
  .greetingEnd:
    align 4
 .end:

stack:
    times 0x1000 dd 0x00000000
  .end:
