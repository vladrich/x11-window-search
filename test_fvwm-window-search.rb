require_relative './lib'
include FvwmWindowSearch
require 'minitest/autorun'

class Windows < Minitest::Test
  def test_invalid_input
    assert_raises(RuntimeError) { Window.new '' }
    assert_raises(RuntimeError) { Window.new 'foo' }
  end

  def test_xterm
    w = Window.new '0x02a0000e  0 xterm.XTerm           hm76 screen'
    assert_equal '0x02a0000e', w.id
    assert_equal 'screen', w.name
    assert_equal 'xterm', w.resource
    assert_equal '0', w.desk
    assert_equal 'hm76', w.host
    assert_equal 'XTerm', w.class
  end

  def test_all_desktops_window
    w = Window.new '0x01400003 -1 FvwmPager.FvwmPager   hm76 Desk 1'
    assert_equal 'Desk 1', w.name
    assert_nil w.desk
  end

end

class WindowList < Minitest::Test
  def setup
    @winlist = [
      '0x00c00004 -1 FvwmIconMan.FvwmIconMan  hm76 FvwmIconMan',
      '0x01400003 -1 FvwmPager.FvwmPager   hm76 Desk 1',
      '0x0280000e  0 mutt.XTerm            hm76 mutt'
    ].map {|v| Window.new v}
  end

  def test_class
    patterns = {
      "name" => [],
      "resource" => [],
      "class" => ['^Fvwm', '!^FvwmPager$']
    }
    wl = windows_filter patterns, @winlist
    assert_equal 2, wl.size
    assert_equal 'Desk 1', wl[0].name
    assert_equal 'mutt', wl[1].name
  end

  def test_class_and_name
    patterns = {
      "name" => ['mutt'],
      "resource" => [],
      "class" => ['^Fvwm', '!^FvwmPager$']
    }
    wl = windows_filter patterns, @winlist
    assert_equal 1, wl.size
    assert_equal 'Desk 1', wl[0].name
  end

  def test_empty_patterns
    patterns = {
      "name" => [],
      "resource" => [],
      "class" => []
    }
    wl = windows_filter patterns, @winlist
    assert_equal 3, wl.size
  end

end
