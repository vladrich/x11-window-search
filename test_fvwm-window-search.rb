require_relative './lib'
include FvwmWindowSearch
require 'minitest/autorun'

class Windows < Minitest::Test
  def test_invalid_input
    assert_raises(RuntimeError) { Window.new '' }
    assert_raises(RuntimeError) { Window.new 'foo' }
  end

  def test_xterm
    w = Window.new '0x3a0000f "screen": ("xterm" "XTerm")  659x388+0+0  +1814+-844'
    assert_equal '0x3a0000f', w.id
    assert_equal 'screen', w.name
    assert_equal 'xterm', w.resource
    assert_equal 'XTerm', w.class
    assert_equal 659, w.width
    assert_equal 388, w.height
    assert_equal 1814, w.x
    assert_equal -844, w.y
    assert_equal 0, w.x_rel
    assert_equal 0, w.y_rel
    assert w.useful?
  end

  def test_not_a_useful_window
    w = Window.new '0x600d2f (has no name): ()  20x20+45+5  +340+36'
    assert_equal '0x600d2f', w.id
    assert_nil w.name
    assert_nil w.resource
    assert_nil w.class
    assert_equal 20, w.width
    assert_equal 20, w.height
    assert_equal 340, w.x
    assert_equal 36, w.y
    assert_equal 45, w.x_rel
    assert_equal 5, w.y_rel
    refute w.useful?
  end

end
