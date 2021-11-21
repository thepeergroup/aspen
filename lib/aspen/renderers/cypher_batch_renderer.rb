module Aspen
  module Renderers
    class CypherBatchRenderer < AbstractRenderer

      # Sort vanilla statements by signature, where signature could be (Person)-[KNOWS]-(Person) or (Company)-[HIRED]->(Person)
      # Use MERGE instead of CREATE because of overlap
      def render
        groups = statements.inject(
          Hash.new { |h, k| h[k] = [] }
          ) do |memo, statement|
            memo[statement.signature] << statement
            memo
        end
        groups.inject("") do |memo, elem|
          signature, statements = elem
          first = statements.first
          memo << ERB.new(template).result_with_hash(
            signature:    signature,
            statements:   statements,
            origin_label: first.origin.label,
            target_label: first.target.label,
            origin_attr:  first.origin.attributes.keys.first,
            target_attr:  first.target.attributes.keys.first,
            edge_cypher:  first.edge.to_cypher,
          )
          memo
        end
      end

      def template
        <<~TEMPLATE
          # <%= signature %>
          {batch: [<% statements.each do |statement| %>
            {from:"<%= statement.origin.attributes.values.first %>",to:"<%= statement.target.attributes.values.first %>"},<% end %>
          ]}

          UNWIND $batch as row
          MATCH (from:<%= origin_label %> {<%= origin_attr %>: row.from})
          MATCH (to:<%= target_label %> {<%= target_attr %>: row.to})
          MERGE (from)<%= edge_cypher %>(to)
        TEMPLATE
      end

    end
  end
end
