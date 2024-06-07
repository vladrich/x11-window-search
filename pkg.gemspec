Gem::Specification.new do |s|
  s.version = '2.3.0'
  s.required_ruby_version = '>= 2.1.0'

  s.name = 'fvwm-window-search'
  s.summary = "A window switcher: an interactive incremental windows search & selection for X Window"
  s.description = <<END
A window switcher: search for windows interactively using a patched
dmenu utility (the gem fetches & patches it during its installation).
This was originally made for Fvwm, but it's been rewritten to work with
any EWMH-compliant stacking window manager.

Requires a preinstalled jansson-devel C library.

It differs from rofi & co in that it activates (brings up) windows
_during_ the search.
END
  s.author = 'Alexander Gromnitsky'
  s.email = 'alexander.gromnitsky@gmail.com'
  s.homepage = 'https://github.com/gromnitsky/fvwm-window-search'
  s.license = 'MIT'
  s.files = [
    'activate.sh',
    'lib.c',
    'activate.c',
    'winlist.c',
    'fontinfo.c',
    'dmenu.patch',
    'Makefile',
    'README.md',
  ]

  s.bindir = '.'
  s.executables = ['fvwm-window-search']
  s.extensions << 'extconf.rb'
end
