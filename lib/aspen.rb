require 'aspen/abstract_parser'
require 'aspen/abstract_statement'
require 'aspen/ast'
require 'aspen/compiler'
require 'aspen/contracts'
require 'aspen/custom_grammar'
require 'aspen/custom_statement'
require 'aspen/discourse'
require 'aspen/edge'
require 'aspen/errors'
require 'aspen/lexer'
require 'aspen/node'
require 'aspen/parser'
require 'aspen/statement'
require 'aspen/system_default'
require 'aspen/version'

module Aspen

  # TODO: There wants to be a pre-compiler stage/object.

  SEPARATOR = "----".freeze

  def self.compile_code(code, environment = {})
    tokens = Lexer.tokenize(code, environment)
    ast = Parser.parse(tokens, environment)
    Compiler.render(ast, environment)
  end

  def self.compile_text(text, environment = {})
    assert_text(text)

    if text.include?(SEPARATOR)
      env, _sep, code = text.partition(SEPARATOR)
      compile_code(code, YAML.load(env).merge(environment))
    else
      code = text
      compile_code(code, environment)
    end
  end

  def self.available_formats
    [:cypher, :json, :gexf]
  end

  private

  def self.assert_text(text)
    if text.strip.empty?
      raise Aspen::Error, "Text must be provided to the `Aspen.compile_text` method."
    end
  end

end
