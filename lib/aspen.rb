require 'aspen/version'
require 'aspen/errors'

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

  def self.compile_text(text)
    if text.strip.empty?
      raise Aspen::Error, "Text must be provided to the `Aspen.compile_text` method."
    end

    head, _sep, body_text = text.partition("----")

    context = Discourse.new(head)
    body    = Body.new(body_text, context: context)

    body.to_cypher
  end

end
