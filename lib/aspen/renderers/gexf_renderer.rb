module Aspen
  module Renderers
    class GexfRenderer < AbstractRenderer

      def render
        joiner = "\n            "
        <<~GEXF
          <gexf xmlns="http://www.gexf.net/1.2draft" version="1.2">
              <graph mode="static" defaultedgetype="directed">
                  <nodes>
                      #{nodes.map(&:strip).join(joiner)}
                  </nodes>
                  <edges>
                      #{relationships.map(&:strip).join(joiner)}
                  </edges>
              </graph>
          </gexf>
        GEXF
      end

      def nodes
        statements.flat_map(&:nodes).map do |node|
          attrs = node.attributes.map do |k, v|
            "#{k}=\"#{v}\""
          end.join(" ")
          <<~GEXF
            <node id="#{node.nickname}" label="#{node.label}" #{attrs}>
          GEXF
        end
      end

      def relationships
        # @todo: Add in Custom Statements
        statements.map.with_index do |st, id|
          if st.is_a? Aspen::CustomStatement
            next # NO OP
          else
            <<~GEXF
              <edge id="#{id}" source="#{st.origin.nickname}" target="#{st.target.nickname}" label="#{st.edge.label}">
            GEXF
          end
        end.compact
      end

    end
  end
end
