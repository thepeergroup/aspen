module Aspen
  module AST
    module Nodes
      class Attribute

        attr_reader :content, :type

        def initialize(content)
          @content = Aspen::AST::Nodes::Content.new(content)
          @type    = Aspen::AST::Nodes::Type.determine(content)
        end

      end
    end
  end
end