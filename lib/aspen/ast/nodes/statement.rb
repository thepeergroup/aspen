module Aspen
  module AST
    module Nodes
      class Statement

        attr_reader :origin, :edge, :target

        def initialize(origin: nil, edge: nil, target: nil)
          @origin = origin
          @edge   = edge
          @target = target
        end

      end
    end
  end
end
