# 0x2400018 "FvwmTabs": ("fvwmTabs" "FvwmTabs")  1x1+0+0  +0+0
# 0x2bc9371 "- [alex@fedora.9bf016]: winlist.rb": ("emacs" "Emacs")  672x725+0+0  +859+149
# 0x3e0000f "mutt": ("mutt" "XTerm")  644x692+0+0  +-926+-804
#
# 0x60822e (has no name): ()  5x788+0+23  +-1391+-843
# 0x2bcd688 "emacs": ("emacs" "Emacs")  260x401+1229+172  +1229+172
# 0x2400016 "Balloon": ("balloon" "Balloon")  1x1+0+0  +0+0
# 0x300003e "Chromium clipboard": ()  10x10+-100+-100  +-100+-100
# 0x80003f "vmware-user": ()  10x10+-100+-100  +-100+-100
class WinListEntry

  def initialize rawline
    @matchdata = nil
    @dimensions = {}

    if rawline
      @matchdata = rawline.match(/^([x0-9a-f]+)\s+["\(](.+)["\)]:\s+\((.*)\)\s+([x0-9+-]+)\s+([0-9+-]+)$/)
    end

    parse_dimensions
  end

  def x11id
    @matchdata[1]
  end

  def name
    @matchdata[2]
  end

  def resource
    return nil unless @matchdata[3]
    r = @matchdata[3].split(' ')[0]
    r = r[1..-2] if r
    r
  end

  def x11class
    return nil unless @matchdata[3]
    r = @matchdata[3].split(' ')[1]
    r = r[1..-2] if r
    r
  end

  def parse_dimensions
    return unless @matchdata

    if @matchdata[4]
      m4 = @matchdata[4].match(/^([0-9]+)x([0-9]+)\+([0-9-]+)\+([0-9-]+)$/)
      if m4
        @dimensions[:w] = m4[1].to_i
        @dimensions[:h] = m4[2].to_i
        @dimensions[:x_rel] = m4[3].to_i
        @dimensions[:y_rel] = m4[4].to_i
      end
    end

    if @matchdata[5]
      m5 = @matchdata[5].match(/^\+([0-9-]+)\+([0-9-]+)$/)
      if m5
        @dimensions[:x] = m5[1].to_i
        @dimensions[:y] = m5[2].to_i
      end
    end
  end

  private :parse_dimensions

  def width
    @dimensions[:w]
  end

  def height
    @dimensions[:h]
  end

  # Absolute upper-left X
  def x
    @dimensions[:x]
  end

  # Absolute upper-left Y
  def y
    @dimensions[:y]
  end

  def x_rel
    @dimensions[:x_rel]
  end

  def y_rel
    @dimensions[:y_rel]
  end

  def onpage?
    return false if x < 0 || y < 0
    true
  end

  def useful?
    return false unless @matchdata
    return false if width == 0 || height == 0
    return false if (x == x_rel) && (y == y_rel)
    return false unless x11class

    true
  end

  def to_s
    page = onpage? ? "[Y]" : "[ ]"
    [name, x11class, page, x11id].join ", "
  end

end

class WinList

  def initialize
    @entries = []
  end

  attr_reader :entries

  def raw
    return [] unless (data = `xwininfo -root -tree`)
    data.split("\n").select do |idx|
      idx.match(/^\s*0x.+/)
    end.map {|idx| idx.strip}
  end

  def parse
    @entries = []
    raw.each do |idx|
      e = WinListEntry.new(idx)
      @entries << e if e.useful?
    end

    @entries
  end

end
