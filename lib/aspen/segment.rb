module Aspen
  Segment = Struct.new(:typedef, :variable) do
    def type
      case typedef
      when /^[A-Z]/ then :node
      when /^numeric$/ then :numeric
      when /^string$/ then :string
      else
        raise Aspen::Error <<~ERROR
          Don't recognize this type. Must be one of:
            numeric, string, or any type of node.
        ERROR
      end
    end

    def pattern
      case type
      when :node    then /(?<#{variable}>.*?)/
      when :numeric then /(?<#{variable}>[\d,]+\.?\d*)/
      when :string  then /(?<#{variable}>\".*?\")/
      end
    end

    def regex
      Regexp.new(pattern)
    end

    def regexp
      regex
    end
  end

end
