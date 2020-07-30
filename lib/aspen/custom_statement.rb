require 'dry/types'

# A result set looks like this:
# {
#   "a"=>[[:SEGMENT_MATCH_NODE, "Person"], "Jeanne"],
#   "role"=>[[:SEGMENT_MATCH_STRING], "\"case manager\""],
#   "count"=>[[:SEGMENT_MATCH_NUMERIC], 1]
# }

module Aspen
  class CustomStatement < AbstractStatement

    include Dry::Monads[:maybe]

    attr_reader :nodes

    def initialize(nodes: , cypher: )
      @nodes  = nodes
      @cypher = cypher
    end

    def to_cypher
      @cypher
    end
  end
end
