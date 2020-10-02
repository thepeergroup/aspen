require 'strscan'

module Aspen
  module CustomGrammar
    class Lexer
      def self.tokenize(code, env={})
        new.tokenize(code, env)
      end

      def tokenize(code, env={})
        scanner = StringScanner.new(code)
        tokens = []

        puts "tokens: #{tokens} | state: #{state} | stack: #{stack}"

        until scanner.eos?
          case state
          when :default then
            if scanner.scan(/\(/)
              tokens << [:OPEN_PARENS]
              push_state :capture_segment
            elsif scanner.scan(/[[[:alnum:]][[:blank:]]\!"\#$%&'*+,\-.\/:;<=>?@\[\\\]^_‘\{\|\}~]+/)
              tokens << [:BARE, scanner.matched]
            else
              no_match(scanner, state)
            end

          when :capture_segment
            if scanner.scan(/\s+/)
              # NO OP
            elsif scanner.scan(/^(numeric|integer|float|string)/)
              tokens << [:TYPE, scanner.matched]
            elsif scanner.scan(Aspen::Lexer::PASCAL_CASE)
              tokens << [:TYPE, ["node", scanner.matched]]
            # TODO: This should only accept legal variable names, like `hello_01`
            elsif scanner.scan(/^\w+/)
              tokens << [:VAR_NAME, scanner.matched]
            elsif scanner.scan(/\)/)
              tokens << [:CLOSE_PARENS]
              pop_state
            else
              no_match(scanner, state)
            end

          else
            raise Aspen::LexError, "There is no matcher for state #{state.inspect}."
          end
        end

        tokens
      end

      def stack
        @stack ||= []
      end

      def state
        stack.last || :default
      end

      def push_state(state)
        stack.push(state)
      end

      def pop_state
        stack.pop
      end

      def no_match(scanner, state)
        raise Aspen::LexError,
                Aspen::Errors.messages(:unexpected_token, scanner, state)
      end

    end
  end
end