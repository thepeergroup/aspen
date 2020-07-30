module Aspen
  module CustomGrammar
    module AST
      module Nodes
        class Expression

          attr_reader :segments

          def initialize(segments=[])
            @segments = segments
          end

        end
      end
    end
  end
end