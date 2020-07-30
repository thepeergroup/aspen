module Aspen
  module CustomGrammar
    module AST
      module Nodes
        class Bare

          attr_reader :content

          def initialize(content)
            @content = Content.new(content)
          end

        end
      end
    end
  end
end