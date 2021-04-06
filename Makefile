out := _out
dmenu := $(out)/dmenu
dmenu.commit := 1a13d0465d1a6f4f74bc5b07b04c9bd542f20ba6

all: $(out)/.dmenu.build $(out)/activate $(out)/winlist

$(out)/.dmenu.build: $(out)/.dmenu.$(dmenu.commit) dmenu.patch
	patch -d $(dmenu) -p1 < dmenu.patch
	make -C $(dmenu)
	touch $@

$(out)/.dmenu.$(dmenu.commit):
	git clone https://git.suckless.org/dmenu $(dmenu)
	git -C $(dmenu) checkout $(dmenu.commit) -q
	touch $@

libs := x11 jansson
LDFLAGS := $(shell pkg-config --libs $(libs))
CFLAGS := -g -Wall $(shell pkg-config --cflags $(libs))
$(out)/%: %.c lib.c
	$(LINK.c) $< $(LOADLIBES) $(LDLIBS) -o $@

# an empty target to satisfy rubygems
install:
