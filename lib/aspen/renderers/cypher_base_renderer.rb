module Aspen
  module Renderers
    class CypherBaseRenderer < AbstractRenderer

      def render
        [
          nodes(statements),
          "\n\n",
          relationships(statements),
          "\n"
        ].join()
      end

      def nodes(input_statements)
        input_statements.
          flat_map(&:nodes).
          map { |node| "MERGE #{node.to_cypher}" }.
          uniq.
          join("\n")
      end

      def relationships(input_statements)
        input_statements.map do |statement|
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
