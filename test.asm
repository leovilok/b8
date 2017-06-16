org 0x20000
bits 32

call f
ret
nop
nop
nop
nop
nop

f:
mov eax, lol
ret
nop
nop

lol dd 42
nop
nop
nop
nop
nop

