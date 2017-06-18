org 0x20000
bits 32

pix:   equ 0x40000
screen_size: equ 0x10000
input: equ 0x50000

header: db '#!/usr/bin/env b8', 0x0a
times 32-$+header db 0x0

jmp [state_fun]
state_fun dd init

init:
	; set initial screen
	mov ecx, screen_size
	.loop:
		push cx
		call colorize
		pop cx
		mov byte [ecx + pix], al
		loop .loop

	mov dword [state_fun], f
	ret

f:
	; update coords
	mov eax, 0
	mov al, byte [input]
	mov ebx, [coords]

	.check_left:
	mov cl, 1b
	and cl, al
	jz .check_right
	sub bx, 1

	.check_right:
	mov cl, 10b
	and cl, al
	jz .check_up
	add bx, 1

	.check_up:
	mov cl, 100b
	and cl, al
	jz .check_down
	sub bx, 0x100

	.check_down:
	mov cl, 1000b
	and cl, al
	jz .check_end
	add bx, 0x100

	.check_end:
	mov [coords], ebx

	; get color
	mov ecx, [coords]
	mov eax, screen_size-1
	sub eax, ecx
	push ax
	call colorize
	add esp, 2

	mov ebx, [coords]
	mov byte [pix+ebx], al
	ret

colorize:
	mov al, 0
	mov bx, 0
	mov cx, [esp+4] ; get fun argument

	;red part
	mov bl, cl
	and bl, 01110000b
	sal bl, 1
	and bl, 11100000b
	or  al, bl

	;green part
	mov bl, ch
	and bl, 01110000b
	sar bl, 1
	sar bl, 1
	and bl, 00011100b
	or  al, bl

	;blue part
	and ch, 10000000b
	mov bl, ch
	and cl, 10000000b
	sar cl, 1
	and cl, 01000000b
	or  bl, cl
	mov cl, 6
	sar bl, cl
	and bl, 00000011b
	or  al, bl

	ret

coords: dd 0x8080

