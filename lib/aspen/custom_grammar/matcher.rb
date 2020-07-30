require 'mustache'

module Aspen
  module CustomGrammar
    class Matcher

      attr_accessor :expression, :template, :pattern, :typereg, :labelreg

      def initialize(expression: , template: , pattern: )
        @expression = expression
        @template   = template
        # SMELL: I don't like this design.
        compiled_grammar = Aspen::CustomGrammar.compile(expression)
        @pattern    = compiled_grammar[:pattern]
        @typereg    = compiled_grammar[:type_registry]
        @labelreg   = compiled_grammar[:label_registry]
      end

      def match?(str)
        pattern.match?(str)
      end

      # Compare against narrative line to get captures
      # Example results: { a: , amt: , b: }
      def captures(str)
        pattern.match(str).named_captures
      end
      alias_method :results, :captures

      def captures!(str)
        unless match?(str)
          raise Aspen::MatchError,
            Aspen::Errors.messages(:no_grammar_match, pattern, str)
        end
        captures(str)
      end

      alias_method :results!, :captures!


    end
  end
end