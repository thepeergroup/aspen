module Aspen
  module CustomGrammar
    class Grammar

      # API Surface:
      #   #add?
      #   #match? (Boolean) -> Does the grammar cover this string, match this case?
      #   #match  (Matcher) -> Request the matcher for this string.
      #   #compile_pattern (Regexp) -> Given a matcher expression, return the Regexp pattern that can match against a string.

      attr_reader :registry

      include Dry::Monads[:maybe]

      def initialize()
        @registry = []
      end

      # Does the given text match a matcher?
      def match?(string)
        !!match(string)
      rescue Aspen::Error
        false
      end

      def match(text)
        results = @registry.select { |m| m.match?(text) }
        warn "Found #{results.count} matches" if results.count > 1
        # raise Aspen::Error, "No results." if results.empty?
        return results.first
      end

      alias_method :matcher_for, :match

      def inspect
        "#<Aspen::Grammar matchers: #{count}>"
      end

      def count
        registry.count
      end

      def add(maybe_matchers)
        matchers = Array(maybe_matchers).flatten
        raise unless matchers.all? { |m| m.is_a? Aspen::CustomGrammar::Matcher }
        matchers.each { |matcher| @registry << matcher }
      end

      # This doesn't quite work, because var results is untyped.
      def render(content)
        matcher  = matcher_for(content).value!
        results  = results_for(content)
        template = matcher.template
        Mustache.render(template, results)
      end

      def results_for(text)
        matcher_for(text).captures!(text)
      end

      def match!(text)
        unless match(text)
          raise Aspen::MatchError, <<~ERROR
            Couldn't find an Aspen grammar that matched the line:

                #{text}

            For more details (if you can), try running this to see all the match patterns:

                Aspen::Grammar.registry.map(&:pattern)

          ERROR
        end
      end

    end
  end
end