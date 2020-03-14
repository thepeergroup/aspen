require 'dry/types'
require 'mustache'

require 'aspen/segment'

module Aspen
  class Matcher

    include Dry::Monads[:maybe]

    IN_PARENS = /(\(.*?\))/
    SEGMENT = /\((\w+\s[A-Za-z0-9_]+)\)/

    attr_accessor :statement, :template

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

    #  |  compare against narrative line to get captures
    #  V
    # { a: , amt: , b: }
    # Handle errors:
    # Does the match pattern get ALL the expected results?
    def matches!(str)
      unless match?(str)
        raise Aspen::MatchError, "Expected pattern:\n\t#{pattern}\nto match\n\t#{str}"
      end
      Hash[
        pattern.match(str).
        named_captures.
        map { |k, v| [k, Aspen::Node.tag(v, true)] }
      ]
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
      Regexp.new(segs.join)
    end

    # Apply match_results to the template
    #  | Set up Relationship, fill in and produce nodes from text.
    #  V That is, initialize the matched Cypher statement from this param
    def render_cypher(narrative)
      unless defined? @template
        raise ArgumentError, "Must define a template before rendering"
      end
      Mustache.render(template, matches!(narrative))
    end
  end
end
