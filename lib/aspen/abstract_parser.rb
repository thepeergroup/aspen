module Aspen
  class AbstractParser

    def self.parse(tokens, env={})
      new(tokens).parse
    end

    # Convenience method
    def self.parse_code(code, env={}, lexer=Aspen::Lexer)
      tokens = lexer.tokenize(code, env)
      parse(tokens, env)
    end

    attr_reader :tokens, :position

    def initialize(tokens, env={})
      @tokens = tokens
      # Nothing is done with environment in the parser.
      # Calling #next will start at 0
      @position = 0
    end

    def expect(*expected_tokens)
      upcoming = tokens[position, expected_tokens.size]

      if upcoming.map(&:first) == expected_tokens
        advance_by expected_tokens.size
        upcoming
      end
    end

    def need(*required_tokens)
      upcoming = tokens[position, required_tokens.size]
      expect(*required_tokens) or raise Aspen::ParseError, <<~ERROR
        Unexpected tokens. Expected #{required_tokens.inspect} but got #{upcoming.inspect}
      ERROR
    end

    def first
      tokens.first
    end

    def last
      tokens.last
    end

    def next_token
      t = tokens[position]
      advance
      return t
    end

    def peek(offset = 0)
      if offset > 0
        tokens[position + 1..position + offset]
      else
        tokens[position]
      end
    end

    private

    def advance
      advance_by 1
    end

    def advance_by(offset = 1)
      @position += offset
    end

  end
end