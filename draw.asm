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
	call inv_cross
	mov eax, f
	mov [state_fun], eax
	ret

f:
	; undraw cross
	call inv_cross

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

	; update color
	.check_x:
	mov cl, 10000b
	and cl, al
	jz .check_no_x
	mov byte [pressing_x], byte 1
	jmp .check_c

	.check_no_x:
	mov cl, [pressing_x]
	mov byte [pressing_x], byte 0
	test cl, cl

	jz .check_c
	mov cl, [selected]
	inc cl
	and cl, [palette_mask]
	mov byte [selected], cl

	; draw pixel
	.check_c
	mov cl, 100000b
	and cl, al
	jz .check_end

	; get color
	mov ecx, 0
	mov cl, byte [selected]
	mov al, byte [palette + ecx]
	mov byte [pix+edx], al

	.check_end:
	mov [coords], edx

	call inv_cross

	ret

inv_cross:
	mov edx, [coords]

	;up
	mov cx, dx
	sub cx, 0x100
	call inv_pix
	sub cx, 0x100
	call inv_pix

	;down
	mov cx, dx
	add cx, 0x100
	call inv_pix
	add cx, 0x100
	call inv_pix

	;left
	mov cx, dx
	dec cx
	call inv_pix
	dec cx
	call inv_pix

	;right
	mov cx, dx
	inc cx
	call inv_pix
	inc cx
	call inv_pix
	
	ret

inv_pix: ;pass coords in cl
	mov al, byte [pix+ecx]
	xor al, ~1
	mov byte [pix+ecx], al
	ret

coords: dd 0x8080
pressing_x: db 0
selected: db 0
palette: db 0, 11b, 11111b, 11100b, 11111100b, 11100000b, 11100011b, ~0
palette_mask: db 7
