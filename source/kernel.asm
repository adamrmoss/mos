bits 16

%include "source/memory.h"
%include "source/text.h"
%include "source/logo.h"


THEME equ DARK_BLUE << 4 | WHITE

org KERNEL

%include "source/text.asm"
%include "source/logo.asm"

start:
    ; Setup Video
    mov ax, TEXT >> 4
    mov es, ax
 
    call hideCursor
    mov ah, THEME
    call cls

    mov ah, THEME
    call drawLogo


