# fvwm-window-search

Incremental window search & immediate switch to the selected window
*during the search*. Uses a patched version of dmenu as a GUI.

    $ gem install fvwm-window-search

![demo](https://thumbs.gfycat.com/GenerousRingedFlicker-small.gif)

* Should work w/ most stackings X11 window managers.
* Filtering by window name/resource/classe.

## Reqs

* Ruby 2.4+
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
  selhook-return-key-focus-only: true
filter:
    name: ['System Monitor']
    resource: []
    class: []
~~~

Subkeys in `dmenu` are the usual CLOs for
[dmenu(1)][]. `selhook-return-key-focus-only` is a custom one, that
enables window focusing on pressing Return only.

[dmenu(1)]: https://manpages.debian.org/unstable/suckless-tools/dmenu.1.en.html

`filter` key tells what windows should be filtered out. Each value in
a subkey is an array of regexes. See the defaults in
`fvwm-window-search` file.

## Bugs

* Tested only w/ Fvwm3.
* No distinction between normal & iconified windows.

## License

MIT.
