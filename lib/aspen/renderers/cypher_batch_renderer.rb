module Aspen
  module Renderers
    class CypherBatchRenderer < AbstractRenderer

      # Sort vanilla statements by signature, where signature could be (Person)-[KNOWS]-(Person) or (Company)-[HIRED]->(Person)
      # Use MERGE instead of CREATE because of overlap
      def render
        groups = statements.inject({}) do |memo, statement|
          memo[statement.signature] << statement
          memo
        end
        groups.each do |signature, statements|
        end
      end

      def nodes
        statements.
          flat_map(&:nodes).
          map { |node| "MERGE #{node.to_cypher}" }.
          uniq.
          join("\n")
      end

      def relationships
        statements.map do |statement|
          if statement.type == :custom
            statement.to_cypher.lines.map { |line| "MERGE #{line}" }.join()
          elsif statement.type == :vanilla
            "MERGE #{statement.to_cypher}"
          else
            raise ArgumentError, "Statement is the wrong type, expected Aspen::CustomStatemen or Aspen::Statement, but got #{statement.class}"
          end
        end.join("\n")
      end

    end
  end
end
