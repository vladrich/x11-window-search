# fvwm-window-search

Incremental window search & immediate switch to the selected window
*during the search*. Uses a patched version of dmenu as a GUI.

    $ gem install fvwm-window-search

![demo](https://sigwait.tk/~alex/junk/fvwm-window-search-2.2.0.gif)

* Should work w/ most EWMH-compliant stackings X11 window managers.
* Filter by window name/resource/class.
* Optionally list windows from the current desktop only.
* Preserve minimised/shaded window states.

## Reqs

* Ruby 2.1+
* `dnf install jansson-devel freetype-devel`

## Compilation

Type `make`. This clones the dmenu repo, patches & builds it. It
doesn't interfere w/ a system-installed dmenu.

## Usage

~~~
$ ./fvwm-window-search -h
Usage: fvwm-window-search [options]
    -c path                     an alternative path to conf.yaml
    -d                          list windows from the current desktop only
    -r                          switch to a window only when <Return> is pressed
~~~

To scroll in dmenu (using Up/Down/Home/End/PgUp/PgDown) without
windows activation, hold <kbd>Shift</kbd>.

To customise dmenu or filtering, create a yaml file
`$XDG_CONFIG_HOME/fvwm-window-search/conf.yaml`, e.g.:

~~~
---
dmenu:
  fn: Monospace-12
  b: false
  selection_hook_activation_return_key_only: true
filter-out:
    name: ['System Monitor']
    resource: []
    class: []
~~~

Subkeys in `dmenu` are the usual CLOs for
[dmenu(1)][]. `selection_hook_activation_return_key_only` is an
equivalent of `-r` CLO.

[dmenu(1)]: https://manpages.debian.org/unstable/suckless-tools/dmenu.1.en.html

`filter-out` key tells what windows should be ignored. Each value in a
subkey is an array of regexes. See the defaults at the top of
`fvwm-window-search` file.

## Start-up time

As a task switcher, the program must not only run fast, but also
*start* fast. I managed to get it under 70ms on my laptop, when you
run `./fvwm-window-search` directly from the repo.

This is not the case with rubygems! The latter generates a stub script
that invokes `./fvwm-window-search` file. This indirection may add
~140ms of additional delay.

## License

MIT.
