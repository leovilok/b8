#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

char buf[0x40000] __attribute__ ((section ("mem_chunk"))) = {0};

int main(int argc, char *argv[]){
	int (*f)(void) = NULL;

	if(argc < 2)
		return 1;

	int fd = open(argv[1], O_RDONLY);
	if(fd == -1) perror("open");
        
	int ret = mprotect(&buf, 4096, PROT_READ|PROT_WRITE|PROT_EXEC);
	if(ret) perror("mprotect");

	int rdsize = read(fd, buf, 27);
	if(rdsize != 27) perror("read");

	f = (void*)buf;

	printf("%d\n",*(int*)f());
	return 0;
}
