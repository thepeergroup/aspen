module Aspen
  module AST
    module Nodes
      class Statement

        attr_reader :origin, :edge, :destination

        def initialize(origin: nil, edge: nil, dest: nil)
          @origin      = origin
          @edge        = edge
          @destination = dest
        end

        alias_method :target, :destination

      end
    end
  end
end
