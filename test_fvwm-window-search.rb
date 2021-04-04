require_relative './lib'
include FvwmWindowSearch
require 'minitest/autorun'

class WindowList < Minitest::Test
  def setup
    @winlist = [
      {
        "desk" => -1,
        "host" => "hm76",
        "name" => "FvwmIconMan",
        "resource" => "FvwmIconMan",
        "class" => "FvwmIconMan",
        "id" => 12582916
      },
      {
        "desk" => -1,
        "host" => "hm76",
        "name" => "Desk 1",
        "resource" => "FvwmPager",
        "class" => "FvwmPager",
        "id" => 20971523
      },
      {
        "desk" => 0,
        "host" => "hm76",
        "name" => "mutt",
        "resource" => "mutt",
        "class" => "XTerm",
        "id" => 41943054
      },
    ]
  end

  def test_class
    patterns = {
      "name" => [],
      "resource" => [],
      "class" => ['^Fvwm', '!^FvwmPager$']
    }
    wl = windows_filter_out patterns, @winlist
    assert_equal 2, wl.size
    assert_equal 'Desk 1', wl[0]['name']
    assert_equal 'mutt', wl[1]['name']
  end

  def test_class_and_name
    patterns = {
      "name" => ['mutt'],
      "resource" => [],
      "class" => ['^Fvwm', '!^FvwmPager$']
    }
    wl = windows_filter_out patterns, @winlist
    assert_equal 1, wl.size
    assert_equal 'Desk 1', wl[0]['name']
  end

  def test_empty_patterns
    patterns = {
      "name" => [],
      "resource" => [],
      "class" => []
    }
    wl = windows_filter_out patterns, @winlist
    assert_equal 3, wl.size
  end

end
