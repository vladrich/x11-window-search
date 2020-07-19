Gem::Specification.new do |s|
  s.version = '1.1.0'

  s.name = 'fvwm-window-search'
  s.summary = "Interactive incremental windows search & selection for X Window"
  s.description = <<END
Search for windows interactively using a patched dmenu utility.
Originally made for Fvwm, it's been fully rewritten to work out-of-the-box
with any window manager. Requires xdotool & xwininfo installed.
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
