module Aspen
  module CustomGrammar
    class Parser < Aspen::AbstractParser

      # expression = { segment }
      # segment = BARE || capture_segment
      # capture_segment = OPEN_PARENS, type, VAR_NAME, CLOSE_PARENS
      # type = { node CONTENT } || numeric | float | integer | string

      def parse
        Aspen::CustomGrammar::AST::Nodes::Expression.new(parse_expression)
      end

      def parse_expression
        segments = []

        # Make sure this returns on empty
        while segment = parse_segment
          segments << segment
          break if tokens[position].nil?
        end

        segments
      end

      def parse_segment
        return parse_bare_segment || parse_capture_segment
        raise Aspen::ParseError, "Didn't match expected tokens, got\n\t#{upcoming.inspect}"
      end

      def parse_bare_segment
        if content = expect(:BARE)
          Aspen::CustomGrammar::AST::Nodes::Bare.new(content.first.last)
        end
      end

      def parse_capture_segment
        if (_, type, var_name, _ = expect(:OPEN_PARENS, :TYPE, :VAR_NAME, :CLOSE_PARENS))
          type_name, label = type.last

          Aspen::CustomGrammar::AST::Nodes::CaptureSegment.new(
            type:     type_name.to_sym,
            var_name: var_name.last,
            label:    label
          )
        end
      end

    end
  end
end
