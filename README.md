# fvwm-window-search

Incremental window search & immediate switch to the selected window
*during the search*.

Uses a patched version of dmenu as a GUI.

![A screenshot of running fvwm-window-search](https://raw.github.com/gromnitsky/fvwm-window-search/master/screnshot1.png)

## Features

* Works w/ any X11 window manager (defaults are for FVWM, though).
* Windows filtering by name/class.

## Requirements

* Ruby 2+.
* `xwininfo` utility (comes w/ `xorg-x11-utils` Fedora package)
* A patched dmenu (see below).
* An ability to programmatically control windows either through WM or
  w/ an external tool like xdotool.
* Linux.

## General Installation

	% make install

It will clone dmenu repo, patch it, compile it, copy all required files
to `$FVWM_USERDIR/fvwm-window-search`. If you don't have FVWM installed
or you are running a different WM, use

	% make install DEST=$HOME/software/fvwm-window-search

## FVWM

1. Make sure `FvwmCommandS` module is loaded. Run

		FvwmCommand "echo hello"

   to test. It must not raise an error.

2. Add to `$FVWM_USERDIR/.fvwm2rc` a function:

		DestroyFunc FuncFvwmRaiseWindow
		AddToFunc FuncFvwmRaiseWindow
		+ I FlipFocus
		+ I Iconify false
		+ I WindowShade false
		+ I Raise
		+ I WarpToWindow 50 8p

3. Bind some keys to run fvwm-window-search. For example `Pause` &
   `Shift-Pause`:

		# pause				cool search of all windows
		Key Pause A	 N Exec exec $FVWM_USERDIR/fvwm-window-search/fvwm-window-search

## Customization

Debug hints:

* Run w/ `-v` flag.
* If the last CLO is `-V`, fvwm-window-search will display its up-to-date
  configuration & exit.

### Config file

In `$FVWM_USERDIR/fvwm-window-search` directory will be
`etc/config.json.sample` file. Rename it to `etc/config.json`.

* `selhook` is a command that dmenu runs after each selection. It must
  contain `%s` where dmenu will insert a (shell quoted) selected
  line. The provided command in `selhook` must extract the id of the
  window from that line.

  It can be tricky to construct a proper command because of the shell
  quoting. If you want something simple, use xdotool like this:

		"xdotool windowraise \\`echo %s | awk -F, '{print \\$NF}'\\`"

  This will probably work w/ any modern WM, not just FVWM.

### Filters

You can filter out any window. In `$FVWM_USERDIR/fvwm-window-search/etc`
directory there are 2 files for that:

* `class.filter` -- X11 class name.
* `name.filter` -- A window title.

## BUGS

* Tested only with FVWM.
* No distinction between normal & iconified windows.
* :circus_tent:

## TODO

* Compile with mruby & incorporate the result into dmenu.
* Make a screencast, ггг.

## License

MIT.
