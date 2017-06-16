CFLAGS=-Wall -Wextra
LDFLAGS=-Wl,--section-start=mem_section=0x20000

PROG=b8
CARTS=$(patsubst %.asm,%.bin,$(wildcard *.asm))

all: $(PROG) $(CARTS)

clean:
	-$(RM) $(PROG) $(CARTS)

%.bin: %.asm
	yasm -f bin $< -o $@
	chmod +x $@

%.bin: %.s
	yasm -f bin -r gas -p gas $< -o $@
