require 'aspen/custom_grammar/ast'
require 'aspen/custom_grammar/lexer'
require 'aspen/custom_grammar/parser'
require 'aspen/custom_grammar/compiler'

require 'aspen/custom_grammar/matcher'
require 'aspen/custom_grammar/grammar'

module Aspen
  module CustomGrammar

    def self.compile(expression)
      tokens = Aspen::CustomGrammar::Lexer.tokenize(expression)
      ast = Aspen::CustomGrammar::Parser.parse(tokens)
      Aspen::CustomGrammar::Compiler.compile(ast)
    end

    def self.compile_pattern(expression)
      self.compile(expression)[:pattern]
    end

  end
end
