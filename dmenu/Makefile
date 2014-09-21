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

.PHONY: clean
clean:
	rm -rf dmenu
