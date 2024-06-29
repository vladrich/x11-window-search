# x11-window-search

A window search and switcher for X11. 

Search a window by its name or class. Activate by choosing a window from
a match list.

If you often have many windows open (potentially over several virtual
desktops), this software is for you.

## History

This project is a variation on
[gromnitsky/fvwm-window-search](https://github.com/gromnitsky/fvwm-window-search)
and reuses some of its code. The main difference is that
*fvwm-window-search* pieces the functionality together from several
separate components written in different languages (like native code,
shell and Ruby scripts), while this project compiles a single native
executable. Furthermore, *fvwm-window-search* has some extra
functionality (like activating windows while you type), which is
ommitted here. Both *fvwm-window-search* and this project use code from
[dmenu](https://tools.suckless.org/dmenu/).

## License

MIT
