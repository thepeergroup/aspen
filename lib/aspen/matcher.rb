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

      tag_segments
      setup_variable_legend
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
        raise Aspen::MatchError, <<~ERR
          Expected pattern:

            #{pattern}

          to match

            #{str}
        ERR
      end
      Hash[
        pattern.match(str).named_captures.map do |capture|
          name, value = *capture
          type = @legend[name]
          case type
          when :SEGMENT_MATCH_NUMERIC
            case value
            when INTEGER then value.delete(',').to_i
            when FLOAT   then value.delete(',').to_f
            else
              raise ArgumentError, "Numeric value #{value} doesn't match INTEGER or FLOAT."
            end
          when :SEGMENT_MATCH_STRING
            value.to_s
          when :SEGMENT_MATCH_NODE
            value
          end
          [name, [type, value]]
        end

      ]
    end

    MATCH_SEGMENT = /(\(.*?\))/
    INNER_SEGMENT = /\((.*?)\)/

    def tag_segments
      @tags = []
      split_statement = @statement.gsub(/\$/, "\\$").split(MATCH_SEGMENT)
      split_statement.each { |segment| tag_segment(segment) }
    end

    def tag_segment(segment)
      tag = if segment.match?(MATCH_SEGMENT)
        typedef, var_name = segment.match(INNER_SEGMENT).captures.first.split(" ")
        segment_type = case typedef
        when /^numeric$/ then :SEGMENT_MATCH_NUMERIC
        when /^string$/  then :SEGMENT_MATCH_STRING
        when /^[A-Z]/    then :SEGMENT_MATCH_NODE
        else
          raise Aspen::BodyError, "No type definition for #{typedef}."
        end
        [:SEGMENT_MATCH, [segment_type, typedef, var_name]]
      else
        [:SEGMENT_TEXT, [segment]]
      end
      @tags << tag
    end

    # Store type information and "hydrate" with it later.
    def setup_variable_legend
      @legend = {}
      @tags.each do |tagged_segment|
        tag, args = tagged_segment
        if tag == :SEGMENT_MATCH
          type, label, var_name = args
          case type
          when :SEGMENT_MATCH_NODE
            @legend[var_name] = [type, label]
          when :SEGMENT_MATCH_NUMERIC
            @legend[var_name] = [type]
          when :SEGMENT_MATCH_STRING
            @legend[var_name] = [type]
          else
            raise ArgumentError, <<~ERR
              Expected one of: SEGMENT_MATCH_NODE, SEGMENT_MATCH_NUMERIC, SEGMENT_MATCH_STRING, got:

                #{type} from #{tagged_segment}

            ERR
          end
        end
      end
    end

    # matcher
    # (Person a) donated $(float amt) to (Person b).
    #  |  figure out type, set capture segments (regex and names)
    #  V
    # match pattern - give this to a PatternSet
    # (?<a>.*?) donated \$(?<amt>\d[\d\,\.]+\d) to (?<b>.*?).$
    def pattern
      segs = @tags.map { |tagged_segment| build_segment(tagged_segment) }
      segs.last.gsub!(/\.$/, '')
      segs.unshift "^"
      segs.push "\\.?$"
      Regexp.new(segs.join)
    end

    def build_segment(tagged_segment)
      tag, args = tagged_segment
      case tag
      when :SEGMENT_MATCH
        type, _label, var_name = args
        Segment.new(type, var_name).regexp.to_s
      when :SEGMENT_TEXT then args.first
      else
        raise ArgumentError, <<~ERR
          Somehow #{tag} got in here, when it should only be :SEGMENT_NODE or :SEGMENT_TEXT
        ERR
      end
    end

  end
end
