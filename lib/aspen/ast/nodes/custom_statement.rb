module Aspen
  module AST
    module Nodes
      class CustomStatement

        attr_reader :content

        def initialize(content)
          @content = Aspen::AST::Nodes::Content.new(content)
        end

      end
    end
  end
end
