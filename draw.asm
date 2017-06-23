org 0x20000
bits 32

pix:   equ 0x40000
screen_size: equ 0x10000
input: equ 0x50000

header: db '#!/usr/bin/env b8', 0x0a
times 32-$+header db 0x0

jmp [state_fun]
state_fun dd f

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
	jz .check_x
	add dx, 0x100

	.check_x:
	mov cl, 10000b
	and cl, al
	jz .check_no_x
	mov byte [pressing_x], byte 1
	jmp .check_end

	.check_no_x:
	mov cl, [pressing_x]
	mov byte [pressing_x], byte 0
	test cl, cl

	jz .check_end
	mov cl, [selected]
	inc cl
	and cl, [palette_mask]
	mov byte [selected], cl

	.check_end:
	mov [coords], edx

	; get color
	mov ecx, 0
	mov cl, byte [selected]
	mov al, byte [palette + ecx]
	mov edx, [coords]
	mov byte [pix+edx], al
	ret


coords: dd 0x8080
pressing_x: db 0
selected: db 0
palette: db 0, 11b, 11111b, 11100b, 11111100b, 11100000b, 11100011b, ~0
palette_mask: db 7
