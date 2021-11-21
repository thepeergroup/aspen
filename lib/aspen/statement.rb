require 'aspen/abstract_statement'

module Aspen
  class Statement < AbstractStatement

    attr_reader :origin, :edge, :target, :type

    def type
      :vanilla
    end

    def signature
      [
        origin.signature,
        edge.signature,
        target.signature
      ].join()
    end

    # @param origin [Aspen::Node]
    # @param edge [Aspen::Edge]
    # @param target [Aspen::Node]
    def initialize(origin: , edge: , target: )
      @origin      = origin
      @edge        = edge
      @target = target
    end

    def nodes
      [origin, target]
    end

    def to_cypher
      [
        origin.nickname_node,
        edge.to_cypher,
        target.nickname_node
      ].join('')
    end

  end
end
