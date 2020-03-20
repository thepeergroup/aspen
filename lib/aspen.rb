require 'aspen/version'
require 'aspen/errors'

require 'aspen/configuration'
require 'aspen/body'
require 'aspen/node'
require 'aspen/edge'

# require 'aspen/types'
require 'aspen/statement'
require 'aspen/custom_statement'
require 'aspen/matcher'
require 'aspen/grammar'

require 'aspen/contracts'
require 'aspen/nickname_registry'

module Aspen

  def self.compile_text(text)
    if text.strip.empty?
      raise Aspen::Error, "Text must be provided to the `Aspen.compile_text` method."
    end

    head, *tail = text.partition("\n\n\n")
    body_text = tail.join().strip()

    context = Configuration.new(head)
    body    = Body.new(body_text, context: context)

    body.to_cypher
  end

end
