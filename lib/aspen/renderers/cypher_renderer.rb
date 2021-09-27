module Aspen
  module Renderers
    class CypherRenderer < AbstractRenderer

      def render
        [
          nodes,
          "\n\n",
          relationships,
          "\n;\n"
        ].join()
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
          if statement.is_a? Aspen::CustomStatement
            statement.to_cypher.lines.map { |line| "MERGE #{line}" }.join()
          elsif statement.is_a? Aspen::Statement
            "MERGE #{statement.to_cypher}"
          else
            raise ArgumentError, "Statement is the wrong type, expected Aspen::CustomStatemen or Aspen::Statement, but got #{statement.class}"
          end
        end.join("\n")
      end

    end
  end
end
