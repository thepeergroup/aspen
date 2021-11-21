require 'aspen/abstract_statement'

module Aspen
  class Statement < AbstractStatement

    attr_reader :origin, :edge, :destination, :type

    # @todo Rename "destination" to "target" everywhere.
    # @todo Eventually, allow partial statements (just origin nodes).

    def type
      :vanilla
    end

    def signature
      [origin.signature, edge.signature, destination.signature].join()
    end

    # @param origin [Aspen::Node]
    # @param edge [Aspen::Edge]
    # @param destination [Aspen::Node]
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
