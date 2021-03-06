#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#include "mem.h"
#include "media.h"

#define CHECK_STD_ERROR(predicate, name) do{\
	if(predicate){\
		perror(name);\
		exit(1);\
	}\
}while(0)

unsigned char mem[MEM_SIZE] __attribute__ ((section ("mem_section"))) = {0};

void load_cart(const char *filename){
	int fd = open(filename, O_RDONLY);
	CHECK_STD_ERROR(fd == -1, "open");

	int ret = mprotect(&mem, MEM_SIZE, PROT_READ|PROT_WRITE|PROT_EXEC);
	CHECK_STD_ERROR(ret, "mprotect");

	int rdsize = read(fd, mem, CART_SIZE);
	CHECK_STD_ERROR(rdsize == -1, "read");
}

int main(int argc, char *argv[]){
	void (*cart_fun)(void) = NULL;

	if(argc < 2) {
		fprintf(stderr, "Usage: %s file.bin\n", argv[0]);
		return 1;
	}

	load_cart(argv[1]);

	cart_fun = (void*)mem+CART_HEADER_SIZE;

	load_media(argv[1]);

	int cont = 1;
	while(cont){
		cont = update_input();

		cart_fun();

		update_graphics();
	}

	unload_media();

	printf("%d\n",(int)mem[SCREEN_MEM_OFFSET]);
	return 0;
}
