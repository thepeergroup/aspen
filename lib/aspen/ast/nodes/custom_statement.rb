module Aspen
  module AST
    module Nodes
      class CustomStatement

        attr_reader :content

        # I wonder: Should the AST for CustomGrammar be grouped
        # into lib/ast? Should the CustomStatement AST node contain
        # the Bare Segments and Capture Segments, along with
        # variables with types and labels?
        def initialize(content)
          @content = Aspen::AST::Nodes::Content.new(content)
        end

      end
    end
  end
end
