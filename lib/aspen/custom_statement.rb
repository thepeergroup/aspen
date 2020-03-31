require 'dry/types'

# It looks up the narrative in the grammar.
# It raises if it can't find one.

# It returns nodes.
# It renders a nicknamed Cypher statement from context.

# Grammar doesn't need context, but this does.

module Aspen
  class CustomStatement

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
    def self.from_text(text, context: )
      new(
        nodes:  make_nodes(text, context),
        cypher: make_cypher(text, context)
      )
    end

    # A result set looks like this:
    # {
    #   "a"=>[[:SEGMENT_MATCH_NODE, "Person"], "Jeanne"],
    #   "role"=>[[:SEGMENT_MATCH_STRING], "\"case manager\""],
    #   "count"=>[[:SEGMENT_MATCH_NUMERIC], 1]
    # }
    def self.make_nodes(text, context)
      results = context.grammar.results_for(text)
      casted_results(results, context).select { |var_name, obj| obj.is_a? Node }.values
    end

    INTEGER = /^([\d,]+)$/
    FLOAT   = /^([\d,]+\.\d+)$/

    def self.casted_results(results, context)
      Hash[results.map do |var_name, node_result|
        type_arr, value = node_result
        type, _ = type_arr

        new_value = case type
        when :SEGMENT_MATCH_NODE
          Node.from_result(node_result, context)
        when :SEGMENT_MATCH_STRING  then value.to_s
        when :SEGMENT_MATCH_NUMERIC
          case value
          when INTEGER then value.delete(',').to_i
          when FLOAT   then value.delete(',').to_f
          else
            raise ArgumentError, "No numeric type match for #{value.inspect}."
          end
        else
          raise ArgumentError, "No type match for #{type.inspect}"
        end
        [var_name, new_value]
      end]
    end

    def self.make_cypher(text, context)
      # Handle Maybes with more care
      matcher = context.grammar.matcher_for(text).value!
      results = context.grammar.results_for(text)
      template = matcher.template
      nicknamed_results = Hash[casted_results(results, context).map do |var_name, obj|
        [
          var_name,
          obj.is_a?(Node) ? obj.nickname_node : obj
        ]
      end]
      Mustache.render(template, nicknamed_results)
    end

    def to_cypher
      @cypher
    end
  end
end


