module Aspen
  module Types

    # We're casting/converting to types in:
    # - Node
    # - Matcher
    # - Matcher > Segment
    # - Templates
    # That's too many places, they're all independent, and they're losing information.

    STRING  = /^"(.+)"$/
    INTEGER = /^([\d,]+)$/
    FLOAT   = /^([\d,]+\.\d+)$/

    Attr = Struct.new(:name, :value) do
      def to_tag
        [
          type,
          [name, AttrValue.new(value).typed]
        ]
      end
    end

    AttrValue = Struct.new(:value) do
      def type
        case value
        when STRING then :ATTR_VALUE_STRING
        when INTEGER then :ATTR_VALUE_INTEGER
        when FLOAT then :ATTR_VALUE_FLOAT
        else
        end
      end

      def typed
        case type
        when :ATTR_VALUE_STRING
          value.match(STRING).captures.first.to_s
        when :ATTR_VALUE_INTEGER
          value.match(INTEGER).captures.first.delete(',').to_i
        when :ATTR_VALUE_FLOAT
          value.match(FLOAT).captures.first.delete(',').to_f
        else
          raise ArgumentError, "No conversion defined for type #{type.inspect}"
        end
      end
    end

  end
end
