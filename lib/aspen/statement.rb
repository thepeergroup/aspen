require 'aspen/abstract_statement'

module Aspen
  class Statement < AbstractStatement

    attr_reader :origin, :edge, :destination

    # Eventually, allow partial statements (just origin nodes).
    # Eventually, rename "destination" to "target" everywhere.

    def initialize(origin: , edge: , destination: )
      @origin      = origin
      @edge        = edge
      @destination = destination
    end

    def nodes
      [origin, destination]
    end

    def to_cypher
      [
        origin.nickname_node,
        edge.to_cypher,
        destination.nickname_node
      ].join('')
    end

  end
end
