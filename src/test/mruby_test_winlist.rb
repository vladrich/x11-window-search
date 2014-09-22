require './helper'
require '../lib/filter'
require '../lib/winlist'

class TestWinList < $testunit_class

  def setup
    WinList.send(:alias_method, :raw_orig, :raw)
    @fake_raw = -> do
      [
       '0xa0000b "FvwmWharf": ("FvwmWharf" "FvwmWharf")  64x320+0+0  +1536+580',
       '0x2bc9371 "- [alex@fedora.9bf016]: winlist.rb": ("emacs" "Emacs")  672x725+0+0  +859+149',
       '0x3e0000f "mutt": ("mutt" "XTerm")  644x692+0+0  +-926+-804',
       '0x1000005 "Desk 0": ("FvwmPager" "FvwmPager")  199x117+0+0  +5+5',
       '0x2bc9371 "- [alex@fedora.9bf016]: foobar": ("emacs" "Emacs")  672x725+0+0  +859+149',

       '0x60822e (has no name): ()  5x788+0+23  +-1391+-843',
       '0x2bcd688 "emacs": ("emacs" "Emacs")  260x401+1229+172  +1229+172',
       '0x2400016 "Balloon": ("balloon" "Balloon")  1x1+0+0  +0+0',
       '0x300003e "Chromium clipboard": ()  10x10+-100+-100  +-100+-100',
       '0x80003f "vmware-user": ()  10x10+-100+-100  +-100+-100',
      ]
    end
  end

  def teardown
    WinList.send(:alias_method, :raw, :raw_orig)
  end

  # requires X11
  def test_parse
    wl = WinList.new
    assert wl.raw.size > 0

    wl.parse
    assert wl.entries.size > 0
#    wl.entries.each do |idx|
#      puts idx.to_s
##      puts "#{idx} #{idx.instance_variable_get '@dimensions'}"
#    end
  end

  def test_get

    WinList.send :define_method, :raw, &@fake_raw

    wl = WinList.new
    assert_equal 5, wl.get.size
    assert_equal 'FvwmWharf, FvwmWharf, [Y], 0xa0000b', wl.get[0].to_s
    assert_equal '- [alex@fedora.9bf016]: winlist.rb, Emacs, [Y], 0x2bc9371', wl.get[1].to_s
    assert_equal 'mutt, XTerm, [ ], 0x3e0000f', wl.get[2].to_s

    wl = WinList.new('pageonly' => true)
    assert_equal 4, wl.get.size
    assert_equal 'FvwmWharf, FvwmWharf, [Y], 0xa0000b', wl.get[0].to_s
    assert_equal '- [alex@fedora.9bf016]: winlist.rb, Emacs, [Y], 0x2bc9371', wl.get[1].to_s

    wl = WinList.new('filter_dir' => 'data/01')
    assert_equal 3, wl.get.size
    assert_equal 'mutt, XTerm, [ ], 0x3e0000f', wl.get[0].to_s
    assert_equal 'Desk 0, FvwmPager, [Y], 0x1000005', wl.get[1].to_s
    assert_equal '- [alex@fedora.9bf016]: foobar, Emacs, [Y], 0x2bc9371', wl.get[2].to_s
  end

end

class TestWinListEntry < $testunit_class
  def setup
    @has_no_name = WinListEntry.new '0x60822e (has no name): ()  5x788+0+23  +-1391+-843'
    @emacs_good = WinListEntry.new '0x2bc9371 "- [alex@fedora.9bf016]: winlist.rb": ("emacs" "Emacs")  672x725+0+0  +859+149'
    @fvwm = WinListEntry.new '0x60001a "FVWM": ("fvwm" "FVWM")  10x10+-10+-10  +-10+-10'
    @stardict_good = WinListEntry.new '0x3a0006f "StarDict": ("stardict" "Stardict")  583x554+0+0  +-1595+-559'
    @stardict_bad = WinListEntry.new '0x3a00076 "StarDict": ("stardict" "Stardict")  24x24+8+28  +222+33'
  end

  def test_empty
    assert_equal false, (WinListEntry.new nil).useful?
    assert_equal false, (WinListEntry.new "").useful?
  end

  def test_x11class
    assert_equal nil, @has_no_name.x11class
    assert_equal nil, @has_no_name.resource

    assert_equal 'Emacs', @emacs_good.x11class
    assert_equal 'emacs', @emacs_good.resource
  end

  def test_id
    assert_equal '0x2bc9371', @emacs_good.x11id
  end

  def test_name
    assert_equal 'has no name', @has_no_name.name
    assert_equal '- [alex@fedora.9bf016]: winlist.rb', @emacs_good.name
  end

  def test_dimensions
    assert_equal 5, @has_no_name.width
    assert_equal 672, @emacs_good.width

    assert_equal 788, @has_no_name.height
    assert_equal 725, @emacs_good.height

    assert_equal(-1391, @has_no_name.x)
    assert_equal 859, @emacs_good.x

    assert_equal(-843, @has_no_name.y)
    assert_equal 149, @emacs_good.y

    assert_equal 0, @emacs_good.x_rel
    assert_equal(-10, @fvwm.x_rel)
  end

  def test_onpage
    assert_equal false, @has_no_name.onpage?
    assert_equal false, @fvwm.onpage?
    assert_equal true, @emacs_good.onpage?
  end

  def test_to_s
    assert_equal 'has no name, , [ ], 0x60822e', @has_no_name.to_s
    assert_equal 'FVWM, FVWM, [ ], 0x60001a', @fvwm.to_s
    assert_equal '- [alex@fedora.9bf016]: winlist.rb, Emacs, [Y], 0x2bc9371', @emacs_good.to_s
  end

  def test_useful
    assert_equal false, @has_no_name.useful?
    assert_equal false, @fvwm.useful?
    assert_equal true, @emacs_good.useful?

    assert_equal true, @stardict_good.useful?
    assert_equal false, @stardict_bad.useful?
  end

end

MTest::Unit.new.run if mruby?
