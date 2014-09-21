require './helper'
require '../lib/winlist'

class TestWinList < $testunit_class

  def setup
    @winlist = WinList.new
  end

  def teardown
  end

  def test_parse
    assert @winlist.raw.size > 0

    @winlist.parse
    assert @winlist.entries.size > 0
  end

end

class TestWinListEntry < $testunit_class
  def setup
    @has_no_name = WinListEntry.new '0x60822e (has no name): ()  5x788+0+23  +-1391+-843'
    @emacs_good = WinListEntry.new '0x2bc9371 "- [alex@fedora.9bf016]: winlist.rb": ("emacs" "Emacs")  672x725+0+0  +859+149'
    @fvwm = WinListEntry.new '0x60001a "FVWM": ("fvwm" "FVWM")  10x10+-10+-10  +-10+-10'
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

end

MTest::Unit.new.run if mruby?
