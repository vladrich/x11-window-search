DEST ?= $(FVWM_USERDIR)/fvwm-window-search

.PHONY: help
help:
	@echo "make compile    # clone & compile dmenu"
	@echo "make install    # install program to $(DEST)"
	@echo "make uninstall  # rm $(DEST) (be careful!)"
	@echo
	@echo "See README.md for details."

.PHONY: check
check:
	@if [ "$$FVWM_USERDIR" = "" ] ; then \
		echo "no FVWM userdir found; run 'make install DEST=/some/dir'" 1>&2; \
		exit 1; \
	fi;

.PHONY: install
install: compile check
	mkdir -p "$(DEST)"
	cp dmenu/dmenu/dmenu "$(DEST)"
	cp src/fvwm-* "$(DEST)"
	cp -R src/lib "$(DEST)"
	cp -R etc "$(DEST)"

.PHONY: uninstall
uninstall: check
	rm -rf "$(DEST)"
	@echo Enjoy!

.PHONY: compile
compile:
	$(MAKE) -C dmenu
