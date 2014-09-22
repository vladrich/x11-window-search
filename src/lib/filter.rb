class Filter

  def initialize file
    raise 'file is required' unless file

    @file = file
    @include = []
    @exclude = []

    parse
  end

  def parse
    open @file do |ios|
      while line = ios.gets
        line.strip!
        next if line.match(/^#/) || line == ""

        if line[0] == '!'
          @include << Regexp.new(line[1..-1])
        else
          line = line[1..-1] if line[0] == '\\' && line[1] == '!'
          @exclude << Regexp.new(line)
        end
      end
    end
  end

  def match str
    @include.each do |pattern|
      return false if str.match pattern
    end

    @exclude.each do |pattern|
      return true if str.match pattern
    end

    false
  end

end
