module Aspen
  class AbstractStatement

    # In the abstract, Statements must:
    #   - return nodes ([Aspen::Node])
    #   - return a Cypher representation of an object (String)
    #   - report their type (custom, vanilla, etc.)

    # @return [String] the type of statement (:vanilla, :custom)
    def type
      raise NotImplementedError, "Find me in #{__FILE__}"
    end

    # @return [String] a short description the relationship contained in the statement
    # @example Company hired a Person
    #   (Company)-[HIRED]->(Person)
    # @example Person knows Person, reciprocally
    #   (Person)-[KNOWS]-(Person)
    def signature
      raise NotImplementedError, "Find me in #{__FILE__}"
    end

    # @return [Array<Aspen::Node>] a list of nodes from the statement
    def nodes
      raise NotImplementedError, "Find me in #{__FILE__}"
    end

    # @return [String] the Cypher query from this particular statement
    def to_cypher
      raise NotImplementedError, "Find me in #{__FILE__}"
    end

  end
end
