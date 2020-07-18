out := _out
dmenu := $(out)/dmenu
dmenu.commit := 9b38fda6feda68f95754d5b8932b1a69471df960

$(out)/.dmenu.build: $(out)/.dmenu.$(dmenu.commit) dmenu.patch
	patch -d $(dmenu) -p1 < dmenu.patch
	make -C $(dmenu)
	touch $@

$(out)/.dmenu.$(dmenu.commit):
	git clone https://git.suckless.org/dmenu $(dmenu)
	git -C $(dmenu) checkout $(dmenu.commit) -q
	touch $@
