require "json"

module FvwmWindowSearch
  def windows; JSON.parse `_out/winlist`; end

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

    winlist.select { |w| desired.call "class", w['class'] }
      .select { |w| desired.call "resource", w['resource'] }
      .select { |w| desired.call "name", w['name'] }
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
