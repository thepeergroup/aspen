module Aspen
  module Renderers
    class CypherBatchRenderer < AbstractRenderer

      # Sorts statements by signature, where signature could be
      #   (Person)-[KNOWS]-(Person) or (Company)-[HIRED]->(Person).
      def render
        groups = statements.inject(
          Hash.new { |h, k| h[k] = [] }
          ) do |memo, statement|
            memo[statement.signature] << statement
            memo
        end
        groups.inject([]) do |memo, elem|
          signature, statements = elem
          if signature == "custom"
            # Delegate custom statements to the base renderer
            memo << CypherBaseRenderer.new(statements, environment).render
          else
            first = statements.first
            values = statements.map do |statement|
              "{from: #{statement.origin.attributes.values.first.inspect}, to: #{statement.target.attributes.values.first.inspect}}"
            end.join(",\n  ")
            memo << ERB.new(template).result_with_hash(
              signature:    signature,
              values:       values,
              origin_label: first.origin.label,
              target_label: first.target.label,
              origin_attr:  first.origin.attributes.keys.first,
              target_attr:  first.target.attributes.keys.first,
              edge_cypher:  first.edge.to_cypher,
            )
          end
          memo
        end.join("\n\n")
      end

      def template
        <<~TEMPLATE
          // <%= signature %>

          WITH [
            <%= values %>
          ] as values

          UNWIND values as row
          MERGE (from:<%= origin_label %> {<%= origin_attr %>: row.from})
          MERGE (to:<%= target_label %> {<%= target_attr %>: row.to})
          MERGE (from)<%= edge_cypher %>(to)
        TEMPLATE
      end

    end
  end
end
