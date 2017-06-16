org 0x20000
bits 32

header: db '#!/usr/bin/env b8', 0x0a
times 32-$+header db 0x0

jmp f
nop
nop
nop
nop
nop

f:
mov eax, [lol]
mov [0x40000], eax
ret
nop
nop

lol db 42
nop
nop
nop
nop
nop

