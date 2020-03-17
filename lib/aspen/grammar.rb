module Aspen
  class Grammar

    attr_reader :registry

    include Dry::Monads[:maybe]

    def initialize()
      @registry = []
    end

    def inspect
      "#<Aspen::Grammar matchers: #{count}>"
    end

    def count
      registry.count
    end

    def add(maybe_matchers)
      matchers = Array(maybe_matchers).flatten
      raise unless matchers.all? { |m| m.is_a? Aspen::Matcher }
      matchers.each { |matcher| @registry << matcher }
    end

    def results_for(text)
      maybe_matcher = matcher_for(text)
      if maybe_matcher.value_or(false)
        maybe_matcher.value!.matches!(text)
      else
        raise Aspen::Error, "No results."
      end
    end

    # Does the given text match a matcher?
    def match?(text)
      !!match(text).value_or(false)
    end

    def match(text)
      Maybe(@registry.detect { |m| m.match?(text) })
    end

    alias_method :matcher_for, :match

    def match!(text)
      unless match(text)
        raise Aspen::LookupError, <<~ERROR
          Couldn't find an Aspen grammar that matched the line:

              #{text}

          For more details (if you can), try running this to see all the match patterns:

              Aspen::Grammar.registry.map(&:pattern)

        ERROR
      end
    end

  end
end
