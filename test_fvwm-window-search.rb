require 'minitest/autorun'
load 'fvwm-window-search'

class Window < Minitest::Test
  def setup
    @fvwmiconman = {
      "desk" => -1,
      "host" => "hm76",
      "name" => "FvwmIconMan",
      "resource" => "FvwmIconMan",
      "class" => "FvwmIconMan",
      "id" => 12582916
    }
    @fvwmpager = {
      "desk" => -1,
      "host" => "hm76",
      "name" => "Desk 1",
      "resource" => "FvwmPager",
      "class" => "FvwmPager",
      "id" => 20971523
    }
    @xterm = {
      "desk" => 0,
      "host" => "hm76",
      "name" => "mutt",
      "resource" => "mutt",
      "class" => "XTerm",
      "id" => 41943054
    }
  end

  def test_class
    patterns = {
      "name" => [],
      "resource" => [],
      "class" => ['^Fvwm', '!^FvwmPager$']
    }
    assert desired patterns, @xterm
    assert desired patterns, @fvwmpager
    refute desired patterns, @fvwmiconman
  end

  def test_class_and_name
    patterns = {
      "name" => ['mutt'],
      "resource" => [],
      "class" => ['^Fvwm', '!^FvwmPager$']
    }
    refute desired patterns, @xterm
    assert desired patterns, @fvwmpager
    refute desired patterns, @fvwmiconman
  end

  def test_empty_patterns
    patterns = {
      "name" => [],
      "resource" => [],
      "class" => []
    }
    assert desired patterns, @xterm
    assert desired patterns, @fvwmpager
    assert desired patterns, @fvwmiconman
  end

end
