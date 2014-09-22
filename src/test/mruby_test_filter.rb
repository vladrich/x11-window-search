require './helper'
require '../lib/filter'
require '../lib/winlist'

class TestFilter < $testunit_class

  def setup
  end

  def teardown
  end

  def test_invalid
    assert_raises(RuntimeError) do
      Filter.new nil
    end

    assert_raises(Errno::ENOENT) do
      Filter.new ''
    end

    assert_raises(RegexpError, ArgumentError) do
      Filter.new 'data/invalid.filter'
    end
  end

  def test_empty
    f = Filter.new "data/empty.filter"
    assert_equal 0, f.instance_variable_get("@include").size
    assert_equal 0, f.instance_variable_get("@exclude").size
    assert_equal false, f.match("foo")
  end

  def test_example1
    f = Filter.new "data/example1.filter"
    assert_equal 1, f.instance_variable_get("@include").size
    assert_equal 2, f.instance_variable_get("@exclude").size

    assert_equal false, f.match("foo")
    assert_equal true, f.match("FvwmPager")
    assert_equal true, f.match("wmsystemtray")
    assert_equal false, f.match("FvwmIdent")
  end

end

MTest::Unit.new.run if mruby?
