module Aspen
  module CustomGrammar
    module AST
      module Nodes
        class CaptureSegment

          attr_reader :type, :var_name, :label

          def initialize(type: , var_name: , label: )
            @type     = type
            @var_name = var_name
            @label    = label
          end

        end
      end
    end
  end
end