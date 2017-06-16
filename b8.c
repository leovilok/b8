#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define CHECK_STD_ERROR(predicate, name) do{\
	if(predicate){\
		perror(name);\
		exit(1);\
	}\
}while(0)

char buf[0x40000] __attribute__ ((section ("mem_chunk"))) = {0};

int main(int argc, char *argv[]){
	void (*cart_fun)(void) = NULL;

	if(argc < 2) {
		fprintf(stderr, "Usage: %s file.bin\n", argv[0]);
		return 1;
	}

	int fd = open(argv[1], O_RDONLY);
	CHECK_STD_ERROR(fd == -1, "open");
        
	int ret = mprotect(&buf, 4096, PROT_READ|PROT_WRITE|PROT_EXEC);
	CHECK_STD_ERROR(ret, "mprotect");

	int rdsize = read(fd, buf, 0x20000);
	CHECK_STD_ERROR(rdsize == -1, "read");

	cart_fun = (void*)buf+0x20;

	cart_fun();

	printf("%d\n",(int)buf[0x20000]);
	return 0;
}
