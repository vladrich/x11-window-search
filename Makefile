out := _out
dmenu := $(out)/dmenu
dmenu.commit := 1a13d0465d1a6f4f74bc5b07b04c9bd542f20ba6

all: $(addprefix $(out)/, .dmenu.build activate winlist fontinfo)

$(out)/.dmenu.build: $(out)/.dmenu.$(dmenu.commit) dmenu.patch
	patch -d $(dmenu) -p1 < dmenu.patch
	make -C $(dmenu)
	touch $@

$(out)/.dmenu.$(dmenu.commit):
	git clone https://git.suckless.org/dmenu $(dmenu)
	git -C $(dmenu) checkout $(dmenu.commit) -q
	touch $@

libs := x11
LDFLAGS = $(shell pkg-config --libs $(libs))
CFLAGS = -g -Wall $(shell pkg-config --cflags $(libs))
$(out)/%: %.c lib.c
	$(LINK.c) $< $(LOADLIBES) $(LDLIBS) -o $@

$(out)/winlist: libs += jansson
$(out)/fontinfo: libs += xft freetype2

# an empty target to satisfy rubygems
install:
