module Aspen
  # TODO: Keep label information somewhere.
  Segment = Struct.new(:typedef, :variable) do
    def pattern
      case typedef
      when :SEGMENT_MATCH_NUMERIC then /(?<#{variable}>[\d,]+\.?\d+)/
      when :SEGMENT_MATCH_STRING  then /(?<#{variable}>\".*?\")/
      when :SEGMENT_MATCH_NODE    then /(?<#{variable}>.*?)/
      else
        raise ArgumentError, "Not a match for a valid segment type"
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
