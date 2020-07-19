module Aspen

  class Statement
    NODE = /(\(.*?\))/

    attr_reader :origin, :edge, :destination

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

=begin

  Should these become validations?
    def self.assert_node_count(nodes, line)
      unless nodes.count == 2
        raise Aspen::StatementError,
          Aspen::Errors.messages(:statement_node_count, nodes, line)
      end
    end

    def self.assert_edge_count(edges, line)
      unless edges.count == 1
        raise Aspen::StatementError,
          Aspen::Errors.messages(:statement_edge_count, edges, line)
      end
    end
=end

  end
end
