module Aspen
  class AbstractStatement

    # In the abstract, Statements must:
    #   - return nodes ([Aspen::Node])
    #   - return a Cypher representation of an object (String)
    def nodes
      raise NotImplementedError, "Find me in #{__FILE__}"
    end

    def to_cypher
      raise NotImplementedError, "Find me in #{__FILE__}"
    end

  end
end