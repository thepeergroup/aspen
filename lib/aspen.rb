require 'aspen/version'
require 'aspen/errors'

require 'aspen/ast'
require 'aspen/lexer'
require 'aspen/parser'
require 'aspen/compiler'

require 'aspen/system_default'

require 'aspen/discourse'
require 'aspen/body'
require 'aspen/node'
require 'aspen/edge'

require 'aspen/statement'
require 'aspen/custom_statement'
require 'aspen/matcher'
require 'aspen/grammar'

require 'aspen/contracts'


module Aspen

  SEPARATOR = "----".freeze

  def self.compile_code(code, environment = {}, debug: false)
    tokens = Lexer.tokenize(code)
    if debug
      puts "--- TOKENS ---"
      puts tokens.inspect
    end
    ast = Parser.parse(tokens)
    if debug
      puts "--- AST ---"
      puts ast.inspect
    end
    Compiler.render(ast, environment)
  end

  def self.compile_text(text, debug: false)
    assert_text(text)

    if text.include?(SEPARATOR)
      env, _sep, code = text.partition(SEPARATOR)
      compile_code(code, YAML.load(env), debug: debug)
    else
      code = text
      compile_code(code, {}, debug: debug)
    end
  end

  def self.old_compile_text(text)
    if text.strip.empty?
      raise Aspen::Error, "Text must be provided to the `Aspen.compile_text` method."
    end

    head, _sep, body_text = text.partition("----")

    context = Discourse.new(head)
    body    = Body.new(body_text, context: context)

    body.to_cypher
  end

  private

  def self.assert_text(text)
    if text.strip.empty?
      raise Aspen::Error, "Text must be provided to the `Aspen.compile_text` method."
    end
  end

end
