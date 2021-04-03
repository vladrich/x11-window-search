module FvwmWindowSearch; end

class FvwmWindowSearch::Window
  def initialize wmctrl_line
    @data = wmctrl_line.match(/^([x0-9a-f]+)\s+(-?\d+)\s+([^\s]+)\s+([^\s]+)\s+(.+)/)
    raise "invalid wmctrl line" unless @data
  end

  def id; @data[1]; end
  def desk; @data[2].to_i < 0 ? nil : @data[2]; end
  def host; @data[4]; end
  def name; @data[5]; end

  def resource_and_class
    str = @data[3]
    r = str.split('.')
    return r if r.size <= 2

    idx = str.index(/[[:upper:]]/)
    return idx ? [ str[0...idx-1], str[idx..-1] ] : r
  end

  def resource; resource_and_class[0]; end
  def class; resource_and_class[1]; end

  def inspect
    "#<Window> id=#{id},desk=#{desk},resource=#{resource},class=#{self.class},host=#{host},name=#{name}"
  end
end

module FvwmWindowSearch
  def windows
    `wmctrl -lx`.split("\n").map {|v| Window.new(v)}
  end

  def windows_filter_out patterns, winlist
    desired = -> (type, value) {
      include = patterns[type].select {|v| v[0] != '!'}
      exclude = patterns[type].select {|v| v[0] == '!'}.map {|v| v[1..-1]}

      exclude.each do |pattern|
        return true if value.match pattern
      end
      include.each do |pattern|
        return false if value.match pattern
      end
      true
    }

    winlist.select { |w| desired.call "class", w.class }
      .select { |w| desired.call "resource", w.resource }
      .select { |w| desired.call "name", w.name }
  end

  def deep_merge first, second
    merger = proc { |_, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    first.merge(second, &merger)
  end

  def errx exit_code, msg
    $stderr.puts "#{File.basename $0} error: #{msg}"
    exit exit_code
  end

  def which cmd
    ENV['PATH'].split(File::PATH_SEPARATOR).map {|v| File.join v, cmd }
      .find {|v| File.executable?(v) && !File.directory?(v) }
  end
end
