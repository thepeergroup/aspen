module Aspen
  module AST
    module Nodes
      class Node

        attr_reader :content, :label

        def initialize(content: , label: nil)
          @content = Aspen::AST::Nodes::Content.new(content)
          @label = Aspen::AST::Nodes::Label.new(label)
        end

      end
    end
  end
end
