out := _out
dmenu := $(out)/dmenu
dmenu.commit := 9b38fda6feda68f95754d5b8932b1a69471df960

all: $(out)/.dmenu.build $(out)/focus $(out)/winlist

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
