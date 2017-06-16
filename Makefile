LDFLAGS=-Wl,--section-start=mem_chunk=0x20000

CARTS=$(patsubst %.asm,%.bin,$(wildcard *.asm))

all: b8 $(CARTS)

clean:
	-$(RM) b8 *.bin

%.bin: %.asm
	yasm -f bin $< -o $@

%.bin: %.s
	yasm -f bin -r gas -p gas $< -o $@
