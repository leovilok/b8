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
	mov eax, draw_loop
	mov [state_fun], eax
	ret

draw_loop:
	; undraw cross
	call inv_cross

	call preprocess_input
	
	; update coords
	mov eax, 0
	mov al, byte [input]
	mov edx, [coords]

	.check_left:
	mov cl, 1b
	and cl, al
	jz .check_right
	dec dl

	.check_right:
	mov cl, 10b
	and cl, al
	jz .check_up
	inc dl

	.check_up:
	mov cl, 100b
	and cl, al
	jz .check_down
	dec dh

	.check_down:
	mov cl, 1000b
	and cl, al
	jz .update_coords
	inc dh
	
	.update_coords:
	mov [coords], edx
	
	; update color
	mov al, byte [pressed_input]
	.check_x:
	mov cl, 10000b
	and cl, al
	jz .check_c

	call inv_cross
	call swap_palette_buffer
	mov ecx, palette_loop
	mov [state_fun], ecx
	ret

	; draw pixel
	.check_c
	mov al, [input]
	mov cl, 100000b
	and cl, al
	jz .check_end

	call draw_point

	.check_end:

	call inv_cross

	ret

palette_loop:
	call draw_palette

	call preprocess_input

	mov eax, 0
	mov al, byte [pressed_input]
	
	.check_x:
	mov cl, 10000b
	and cl, al
	jz .check_left
	call swap_palette_buffer
	mov ecx, draw_loop
	mov [state_fun], ecx
	ret

	; move color cursor

	.check_left:
	mov eax, 0
	mov al, byte [pressed_input]
	
	mov cl, 1b
	and cl, al
	jz .check_right
	
	mov cl, [selected]
	inc cl
	and cl, [palette_mask]
	mov byte [selected], cl

	.check_right:
	mov cl, 10b
	and cl, al
	jz .check_up
	
	mov cl, [selected]
	dec cl
	and cl, [palette_mask]
	mov byte [selected], cl

	; change draw point radius
	.check_up:
	mov cl, 100b
	and cl, al
	jz .check_down
	
	mov cl, [radius]
	inc cl
	cmp cl, 5
	jle .no_huge_radius
	dec cl
	.no_huge_radius
	and cl, [palette_mask]
	mov byte [radius], cl

	.check_down:
	mov cl, 1000b
	and cl, al
	jz .check_end
	
	mov cl, [radius]
	dec cl
	jnz .no_null_radius
	inc cl
	.no_null_radius:
	and cl, [palette_mask]
	mov byte [radius], cl

	.check_end:

	ret

inv_cross:
	mov edx, [coords]
	mov ecx, 0

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
	mov eax, 0
	mov al, byte [pix+ecx]
	xor al, ~0
	mov byte [pix+ecx], al
	ret

draw_palette:
	mov ecx, 0xf
	mov edx, pix
	
	.y_loop:
		push ecx
		
		; this gives a slight slant to color cells
		; but it's actually funny
		mov ecx, 0xff

		.x_loop:
			push edx
			
			; get color id
			mov edx, ecx
			sar edx, 5

			mov eax, 0
			mov al, [selected]

			;spagetti party!
			cmp al, dl
			je .draw_selected

			.draw_direct:
			mov al, byte [palette + edx]
			jmp .draw

			.draw_selected:
			;TODO: remove hardcoded values
			;      limiting to 16 color palettes

			;column borders
			mov eax, ecx
			and eax, 0x1f
			cmp eax, 4
			jl .do_it

			cmp eax, 27
			jg .do_it

			;line borderes
			mov eax, [esp+4]
			cmp eax, 4
			jl .do_it

			cmp eax, 13
			jg .do_it

			jmp .draw_direct

			.do_it
			mov al, byte [palette + edx]
			xor al, ~0

			.draw:
			pop edx
			mov [edx], al ; put color to screen
			inc edx
		loop .x_loop

		pop ecx
	loop .y_loop

	; draw a point to show the radius

	mov edx, [coords]
	push edx
	
	mov al, byte [selected]
	push eax
	
	; set point coords
	mov dh, 7

	mov dl, 7
	sub dl, al
	sal dl, 5
	add dl, 8

	mov [coords], edx

	; set point color

	cmp al, 0
	jne .no_black
	
	mov al, 7
	
	jmp .store_selected

	.no_black:

	mov al, 0

	.store_selected:

	mov byte [selected], al

	; draw point
	
	call draw_point

	pop eax
	mov byte [selected], al
	
	pop edx
	mov [coords], edx

	ret

swap_palette_buffer:
	mov ecx, 0x1000
	
	.loop:
		mov al, byte [pix + ecx]
		mov dl, byte [palette_buffer + ecx]
		mov byte [pix + ecx], dl
		mov byte [palette_buffer + ecx], al
	loop .loop

	ret

preprocess_input:
	mov al, byte [new_input]
	mov byte [old_input], al
	mov cl, byte [input]
	mov byte [new_input], cl

	xor al, ~0
	and cl, al
	mov byte [pressed_input], cl
	
	mov al, byte [old_input]
	mov cl, byte [new_input]
	xor cl, ~0
	and al, cl
	mov byte [released_input], cl

	ret

draw_point:
	; get topright corner
	mov edx, [coords]
	mov ecx, [radius]

	sub dh, cl
	inc dh
	add dl, cl
	
	; cover the square surface
	mov ecx, [radius]
	sal ecx, 1
	dec ecx
	.x_loop:
		push ecx
		mov ecx, [radius]
		sal ecx, 1
		dec ecx
		
		; get to the left side
		sub dl, cl
		.y_loop
			push ecx

			; get color & draw pixel
			mov ecx, 0
			mov eax, 0
			mov cl, byte [selected]
			mov al, byte [palette + ecx]
			mov byte [pix+edx], al

			pop ecx

			; go one pixel right
			inc dl
		loop .y_loop
		pop ecx

		; go one pixel down
		inc dh
	loop .x_loop
	ret

old_input: db 0
new_input: db 0
pressed_input:  db 0
released_input: db 0

coords: dd 0x8080

radius: dd 0x2

selected: db 0
palette: db 0, 11b, 11111b, 11100b, 11111100b, 11100000b, 11100011b, ~0
palette_mask: db 7
palette_buffer: db 0 ;times 0x1000 db 0 ;256 col * 16 lines
