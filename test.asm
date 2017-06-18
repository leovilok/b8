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
	mov edx, [coords]

	.check_left:
	mov cl, 1b
	and cl, al
	jz .check_right
	sub dx, 1

	.check_right:
	mov cl, 10b
	and cl, al
	jz .check_up
	add dx, 1

	.check_up:
	mov cl, 100b
	and cl, al
	jz .check_down
	sub dx, 0x100

	.check_down:
	mov cl, 1000b
	and cl, al
	jz .check_end
	add dx, 0x100

	.check_end:
	mov [coords], edx

	; get color
	mov ecx, [coords]
	mov eax, screen_size-1
	sub eax, ecx
	push ax
	call colorize
	add esp, 2

	mov edx, [coords]
	mov byte [pix+edx], al
	ret

colorize:
	mov al, 0
	mov dx, 0
	mov cx, [esp+4] ; get fun argument

	;red part
	mov dl, cl
	and dl, 01110000b
	sal dl, 1
	and dl, 11100000b
	or  al, dl

	;green part
	mov dl, ch
	and dl, 01110000b
	sar dl, 1
	sar dl, 1
	and dl, 00011100b
	or  al, dl

	;dlue part
	and ch, 10000000b
	mov dl, ch
	and cl, 10000000b
	sar cl, 1
	and cl, 01000000b
	or  dl, cl
	mov cl, 6
	sar dl, cl
	and dl, 00000011b
	or  al, dl

	ret

coords: dd 0x8080

