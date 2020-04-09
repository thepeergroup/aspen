module Aspen
  module AST
    module Nodes
      class Statement

        attr_reader :statements

        def initialize(origin: nil, edge: nil, dest: nil)
          @origin = origin
          @edge   = edge
          @dest   = dest
        end

      end
    end
  end
end
