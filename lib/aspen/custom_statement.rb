require 'dry/types'

module Aspen
  class CustomStatement

    # It looks up the narrative in the grammar.
    # It raises if it can't find one.

    # It returns nodes.
    # It renders a nicknamed Cypher statement from context.

    # Grammar doesn't need context, but this does.

    include Dry::Monads[:maybe]

    attr_reader :nodes

    def initialize(nodes: , cypher: nil)
      @nodes = Array(nodes)

      if Maybe(cypher).value_or(false)
        @cypher = cypher
      end
    end

    # Example: text: "Matt gave Helene a donation."
    # Results:
    # => nodes: Matt, Helene
    # => to_cypher
    def self.from_text(text, context: )
      new(
        nodes:  make_nodes(text, context),
        cypher: make_cypher(text, context)
      )
    end

    def self.make_nodes(text, context)
      results = context.grammar.results_for(text)
      node_results = results.select do |_, value|
        _text, type = value
        type == :node
      end
      cast(node_results, context).compact.map(&:last)
    end

    def self.make_cypher(text, context)
      # Handle Maybes with more care
      matcher = context.grammar.matcher_for(text).value!
      results = context.grammar.results_for(text)
      template = matcher.template
      Mustache.render(template, cast(results, context, true))
    end

    def self.cast(results, context, for_render = false)
      Hash[results.map do |key, value|
        content, type = value
        new_value = if type == :node
           # FIXME: This is a bad interface.
          n = Node.tag(content, true, context)
          for_render ? n.nickname_node : n
        else
          content
        end
        [key, new_value]
      end]
    end

    def to_cypher
      @cypher
    end
  end
end


