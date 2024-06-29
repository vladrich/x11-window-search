include config.mk

SRC = drw.c dmenu.c util.c winlist.c lib.c activate.c
OBJ = $(SRC:.c=.o)

all: x11-window-search

.c.o:
	$(CC) -c $(CFLAGS) $<

config.h:
	cp config.def.h $@

$(OBJ): arg.h config.h config.mk drw.h xw.h

x11-window-search: dmenu.o drw.o util.o winlist.o activate.o
	$(CC) -o $@ dmenu.o drw.o util.o winlist.o activate.o $(LDFLAGS)

clean:
	rm -f x11-window-search $(OBJ) x11-window-search-$(VERSION).tar.gz

dist: clean
	mkdir -p x11-window-search-$(VERSION)
	cp LICENSE Makefile README.md arg.h config.def.h config.mk\
		drw.h util.h xw.h $(SRC)\
		x11-window-search-$(VERSION)
	tar -cf x11-window-search-$(VERSION).tar x11-window-search-$(VERSION)
	gzip x11-window-search-$(VERSION).tar
	rm -rf x11-window-search-$(VERSION)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f x11-window-search $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/x11-window-search

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/x11-window-search

.PHONY: all clean dist install uninstall
