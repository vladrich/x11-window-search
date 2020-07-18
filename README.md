# fvwm-window-search

Incremental window search & immediate switch to the selected window
*during the search*. Uses a patched version of dmenu as a GUI.

    $ gem install fvwm-window-search

![A screenshot of running fvwm-window-search](https://raw.github.com/gromnitsky/fvwm-window-search/master/screnshot1.png)

* Should work w/ any X11 window manager.
* Filtering by windows names/resources/classes.

## Reqs

* Ruby (tested w/ 2.7.0)
* `xwininfo` & `xdotool` (`xorg-x11-utils` & `xdotool` Fedora pkgs)

## Compilation

Type `make`. This clones the dmenu repo, patches & builds it. It does
not contravene w/ a system-installed dmenu.

## Usage

Run `fvwm-window-search`.

To customise dmenu or filtering, create a yaml file
`$XDG_CONFIG_HOME/fvwm-window-search/conf.yaml`, e.g.:

~~~
---
dmenu:
  fn: Monospace-12
  b: false
filter:
    name: ['System Monitor']
~~~

This passes to dmenu `-fn` & `-b` CLOs & instructs to filter out any
window that matches `System Monitor` regexp in its title.

See the defaults in `fvwm-window-search` file.

## Bugs

* Tested only w/ Fvwm3.
* No distinction between normal & iconified windows.

## License

MIT.
