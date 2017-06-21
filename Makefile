CFLAGS=-Wall -Wextra
LDFLAGS=-Wl,--section-start=mem_section=0x20000
LDLIBS=-lSDL2

PREFIX=/usr/local
BINDIR=$(PREFIX)/bin

PROG=b8
CARTS=$(patsubst %.asm,%.bin,$(wildcard *.asm))

INSTALL_LIST=install.list

all: $(PROG) $(CARTS)

clean:
	-$(RM) $(PROG) $(CARTS)

$(PROG): media.c

%.bin: %.asm
	yasm -f bin $< -o $@
	chmod +x $@

%.bin: %.s
	yasm -f bin -r gas -p gas $< -o $@

install: all
	install -m0755 $(PROG) $(DESTDIR)$(BINDIR)
	echo $(DESTDIR)$(BINDIR)/$(PROG) >> $(INSTALL_LIST)

uninstall: $(INSTALL_LIST)
	$(RM) $(foreach installed,$(file < $(INSTALL_LIST)),$(installed))
	$(RM) $(INSTALL_LIST)

