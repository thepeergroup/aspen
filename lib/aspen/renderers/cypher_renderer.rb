require 'aspen/renderers/cypher_base_renderer'
require 'aspen/renderers/cypher_batch_renderer'

module Aspen
  module Renderers
    class CypherRenderer < AbstractRenderer

      def render(batch: false)
        if batch
          CypherBatchRenderer.new(statements).render
        else
          CypherBaseRenderer.new(statements).render
        end
      end

    end
  end
end
