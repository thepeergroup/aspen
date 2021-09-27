module Aspen
  module Renderers
    class JsonRenderer < AbstractRenderer

      def render
        {
          nodes: nodes,
          edges: relationships
        }.to_json
      end

      def nodes
        statements.flat_map(&:nodes).map do |node|
          node.attributes.merge({
            id: node.nickname,
            label: node.label
          })
        end
      end

      def relationships
        statements.map.with_index do |st, id|
          # @todo: Add in Custom Statements
          if st.is_a? Aspen::CustomStatement
            next # NO OP
          else
            {
              id: "e#{id}",
              source: st.origin.nickname,
              target: st.destination.nickname,
              label: st.edge.label,
              reciprocal: st.edge.reciprocal?
            }
          end
        end.compact
      end

    end
  end
end
