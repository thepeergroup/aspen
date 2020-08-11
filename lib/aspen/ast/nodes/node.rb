module Aspen
  module AST
    module Nodes
      class Node

        attr_reader :attribute, :label

        def initialize(attribute: , label: nil)
          @attribute = Aspen::AST::Nodes::Attribute.new(attribute)
          @label     = Aspen::AST::Nodes::Label.new(label)
        end

        def label=(content)
          @label = Aspen::AST::Nodes::Label.new(content)
        end

      end
    end
  end
end
