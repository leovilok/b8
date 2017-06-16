#include <stdlib.h>
#include <stdio.h> //do I really need this?

#include <SDL2/SDL.h>

#include "mem.h"

#include "media.h"

#define SCREEN_WIDTH 256
#define SCREEN_HEIGHT 256

enum keys {
	LEFT,
	RIGHT,
	UP,
	DOWN,
	X,
	C,
	RETURN,
	ESCAPE,
};

SDL_Window *window;
SDL_Renderer *renderer;
SDL_Texture *texture;
SDL_Rect rect = {.x=0,.y=0,.w=SCREEN_WIDTH,.h=SCREEN_HEIGHT};

void load_media(const char *name){
	//TODO: check every init
	SDL_Init( SDL_INIT_EVERYTHING );
	window = SDL_CreateWindow(
			name,
			SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
			SCREEN_WIDTH, SCREEN_HEIGHT,
			0);

	renderer = SDL_CreateRenderer(
			window, -1,
			SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);

	texture = SDL_CreateTexture(
			renderer,
			SDL_PIXELFORMAT_RGB332, SDL_TEXTUREACCESS_STREAMING,
			SCREEN_WIDTH, SCREEN_HEIGHT);

	SDL_RenderClear(renderer);
}

void unload_media(){
	SDL_DestroyTexture(texture);
	SDL_DestroyRenderer(renderer);
	SDL_DestroyWindow(window);
	SDL_Quit();
}

void update_graphics(){
	void *mem_pixels = mem+SCREEN_MEM_OFFSET;
	void *texture_pixels;
	int pitch; /* we don't actually use this, yolo */
	SDL_LockTexture(texture, &rect, &texture_pixels, &pitch);
	memcpy(texture_pixels, mem_pixels, SCREEN_MEM_SIZE);
	SDL_UnlockTexture(texture);

	SDL_RenderCopy(renderer, texture, &rect, &rect);
	SDL_RenderPresent(renderer);
	SDL_RenderClear(renderer);
}

int update_input(){
	unsigned char *input = mem+INPUT_MEM_OFFSET;
	SDL_Event e;

	while (SDL_PollEvent(&e)) {
		if (e.type == SDL_QUIT) {
			return 0;
		}
		if (e.type == SDL_KEYDOWN) {
			switch (e.key.keysym.sym) {
				case SDLK_LEFT:
					*input |= 1<<LEFT;
					break;

				case SDLK_RIGHT:
					*input |= 1<<RIGHT;
					break;

				case SDLK_UP:
					*input |= 1<<UP;
					break;

				case SDLK_DOWN:
					*input |= 1<<DOWN;
					break;

				case SDLK_x:
					*input |= 1<<X;
					break;

				case SDLK_c:
					*input |= 1<<C;
					break;

				case SDLK_RETURN:
					*input |= 1<<RETURN;
					break;

				case SDLK_ESCAPE:
					*input |= 1<<ESCAPE;
					break;

				case SDLK_q:
					return 0;
				default:
					break;

			}
		}

		if (e.type == SDL_KEYUP) {
			switch (e.key.keysym.sym) {
				case SDLK_LEFT:
					*input &= ~(1<<LEFT);
					break;

				case SDLK_RIGHT:
					*input &= ~(1<<RIGHT);
					break;

				case SDLK_UP:
					*input &= ~(1<<UP);
					break;

				case SDLK_DOWN:
					*input &= ~(1<<DOWN);
					break;

				case SDLK_x:
					*input &= ~(1<<X);
					break;

				case SDLK_c:
					*input &= ~(1<<C);
					break;

				case SDLK_RETURN:
					*input &= ~(1<<RETURN);
					break;

				case SDLK_ESCAPE:
					*input &= ~(1<<ESCAPE);
					break;
			}
		}

	}

	return 1;
}
