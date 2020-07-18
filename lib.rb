module FvwmWindowSearch; end

class FvwmWindowSearch::Window
  def initialize xwininfo_line
    @line = xwininfo_line.match(/^([x0-9a-f]+)\s+(["\(].+["\)]):\s+\((.*)\)\s+([x0-9+-]+)\s+([0-9+-]+)$/)
    raise "invalid xwininfo line" unless @line
    @dim = parse
  end

  def parse
    dim = {}
    if @line[4]
      m4 = @line[4].match(/^([0-9]+)x([0-9]+)\+([0-9-]+)\+([0-9-]+)$/)
      if m4
        dim[:w] = m4[1].to_i
        dim[:h] = m4[2].to_i
        dim[:x_rel] = m4[3].to_i
        dim[:y_rel] = m4[4].to_i
      end
    end

    if @line[5]
      m5 = @line[5].match(/^\+([0-9-]+)\+([0-9-]+)$/)
      if m5
        dim[:x] = m5[1].to_i
        dim[:y] = m5[2].to_i
      end
    end

    dim
  end

  def id; @line[1]; end

  def name;
    return unless @line[2]
    @line[2] == '(has no name)' ? nil : @line[2][1..-2]
  end

  def resource; @line[3]&.split(' ')&.dig(0)&.slice(1..-2); end
  def class;    @line[3]&.split(' ')&.dig(1)&.slice(1..-2); end
  def width; @dim[:w]; end
  def height; @dim[:h]; end
  def x; @dim[:x]; end # an absolute upper-left X
  def y; @dim[:y]; end # an absolute upper-left Y
  def x_rel; @dim[:x_rel]; end
  def y_rel; @dim[:y_rel]; end

  def useful?
    return false unless @line
    return false if width == 0 || height == 0
    return false if (x == x_rel) && (y == y_rel)
    return false if x_rel > 0 || y_rel > 0
    return false unless self.class
    true
  end

  def inspect
    "#<Window> id=#{id}, name=#{name}, resource=#{resource}, class=#{self.class}"
  end
end

module FvwmWindowSearch
  def windows
  `xwininfo -root -tree`.split("\n")
    .select {|v| v.match(/^\s*0x.+/)}
    .map(&:strip)
    .map {|v| Window.new(v)}
    .select(&:useful?)
  end

  # TODO: check patterns
  def windows_filter patterns, winlist
    desired = -> (type, value) {
      include = patterns[type].filter{|v| v[0] != '!'}
      exclude = patterns[type].filter{|v| v[0] == '!'}.map {|v| v[1..-1]}

      exclude.each do |pattern|
        return true if value.match pattern
      end
      include.each do |pattern|
        return false if value.match pattern
      end
      true
    }

    winlist.filter { |w| desired.call "class", w.class }
      .filter{ |w| desired.call "resource", w.resource }
      .filter{ |w| desired.call "name", w.name }
  end

  def deep_merge first, second
    merger = proc { |_, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    first.merge(second, &merger)
  end

  def errx exit_code, msg
    $stderr.puts "#{File.basename $0} error: #{msg}"
    exit exit_code
  end

end
