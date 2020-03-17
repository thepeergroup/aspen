require 'dry/types'
require 'mustache'

require 'aspen/segment'

module Aspen
  class Matcher

    include Dry::Monads[:maybe]

    IN_PARENS = /(\(.*?\))/
    SEGMENT = /\((\w+\s[A-Za-z0-9_]+)\)/

    attr_accessor :statement, :template

    # TODO: Validate that we have everything we need before matching.
    # TODO: convert the {{}} to {{{}}} in the template.
    def initialize(statement, template = nil)
      @statement = statement

      if Maybe(template).value_or(false)
        @template = template
      end
    end

    def match?(str)
      pattern.match?(str)
    end

    def matches(str)
      matches!(str)
    rescue Aspen::MatchError
      false
    end

    # Compare against narrative line to get captures
    # Example results: { a: , amt: , b: }
    def matches!(str)
      unless match?(str)
        raise Aspen::MatchError, "Expected pattern:\n\t#{pattern}\nto match\n\t#{str}"
      end
      Hash[
        pattern.match(str).named_captures.map { |capture| cast_and_tag(capture) }
      ]
    end

    STRING  = /^"(.+)"$/
    INTEGER = /^([\d,]+)$/
    FLOAT   = /^([\d,]+\.\d+)$/

    def cast_and_tag(capture)
      key, value = *capture
      name, _type = key.to_s.split("-")
      type = _type.to_sym

      casted_value = case type.to_sym
      when :numeric
        case value
        when INTEGER then value.delete(',').to_i
        when FLOAT   then value.delete(',').to_f
        else
          raise ArgumentError, "Numeric value #{value} doesn't match INTEGER or FLOAT."
        end
      else
        value
      end

      [name, [casted_value, type.to_sym]]
    end

    MATCH_SEGMENT = /(\(.*?\))/
    INNER_SEGMENT = /\((.*?)\)/

    # matcher
    # (Person a) donated $(float amt) to (Person b).
    #  |  figure out type, set capture segments (regex and names)
    #  V
    # match pattern - give this to a PatternSet
    # (?<a>.*?) donated \$(?<amt>\d[\d\,\.]+\d) to (?<b>.*?).$
    def pattern
      segs = @statement.gsub(/\$/, "\\$").split(MATCH_SEGMENT).map do |segment|
        if segment.match?(MATCH_SEGMENT)
          typedef, var = segment.match(INNER_SEGMENT).captures.first.split(" ")
          Segment.new(typedef, var).regexp.to_s
        else
          segment
        end
      end
      segs.last.gsub!(/\.$/, '')
      segs.unshift "^"
      segs.push "\\.?$"
      Regexp.new(segs.join)
    end

  end
end
