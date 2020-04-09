module Aspen
  module AST
    module Nodes
      class Narrative

        attr_reader :statements

        def initialize(statements)
          @statements = statements
        end

      end
    end
  end
end
