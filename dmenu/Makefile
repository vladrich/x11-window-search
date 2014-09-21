.PHONY: all
all: compile

.PHONY: compile
compile: patch
	cd dmenu && $(MAKE)

.PHONY: patch
patch: dmenu
	-cd $< && patch -N -r - -p1 < ../selhook.patch

dmenu:
	git clone git://git.suckless.org/dmenu
	cd $@ && git checkout 13a529ce63364544bdc851dfd5d3aa2ef8740914

.PHONY: clean
clean:
	rm -rf dmenu
