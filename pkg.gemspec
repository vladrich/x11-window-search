Gem::Specification.new do |s|
  s.version = '1.2.0'
  s.required_ruby_version = '>= 2.4.0'

  s.name = 'fvwm-window-search'
  s.summary = "A window switcher: an interactive incremental windows search & selection for X Window"
  s.description = <<END
A window switcher: search for windows interactively using a patched
dmenu utility (comes with the gem). This was originally made for Fvwm,
but it's been fully rewritten to work out-of-the-box with any stacking
window manager. Requires xdotool & xwininfo installed.

It differs from rofi & co in that it activates (brings up) windows
_during_ the search.
END
  s.author = 'Alexander Gromnitsky'
  s.email = 'alexander.gromnitsky@gmail.com'
  s.homepage = 'https://github.com/gromnitsky/fvwm-window-search'
  s.license = 'MIT'
  s.files = [
    'focus.sh',
    'lib.rb',
    'dmenu.patch',
    'Makefile',
    'README.md',
  ]

  s.bindir = '.'
  s.executables = ['fvwm-window-search']
  s.extensions << 'extconf.rb'
end
