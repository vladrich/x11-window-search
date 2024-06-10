# dmenu - dynamic menu
# See LICENSE file for copyright and license details.

include config.mk

SRC = drw.c dmenu.c util.c winlist.c lib.c activate.c
OBJ = $(SRC:.c=.o)

all: dmenu

.c.o:
	$(CC) -c $(CFLAGS) $<

config.h:
	cp config.def.h $@

$(OBJ): arg.h config.h config.mk drw.h xw.h

dmenu: dmenu.o drw.o util.o winlist.o activate.o
	$(CC) -o $@ dmenu.o drw.o util.o winlist.o activate.o $(LDFLAGS)

clean:
	rm -f dmenu $(OBJ) dmenu-$(VERSION).tar.gz

dist: clean
	mkdir -p dmenu-$(VERSION)
	cp LICENSE Makefile README arg.h config.def.h config.mk\
		drw.h util.h xw.h $(SRC)\
		dmenu-$(VERSION)
	tar -cf dmenu-$(VERSION).tar dmenu-$(VERSION)
	gzip dmenu-$(VERSION).tar
	rm -rf dmenu-$(VERSION)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f dmenu $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/dmenu

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/dmenu

.PHONY: all clean dist install uninstall
