module Aspen
  module CustomGrammar
    class Compiler

      attr_reader :root, :environment

      def self.render(root, environment = {})
        new(root, environment).render
      end

      def self.compile(root, environment = {})
        new(root, environment).compile
      end

      def initialize(root, environment = {})
        @root = root
        @environment = environment
        @type_registry  = {}
        @label_registry = {}
      end

      def compile
        # Call #render before accessing the registry. If this code
        # changes, we may need more process control to ensure #render
        # goes first.
        {
          pattern: render,
          type_registry: @type_registry,
          label_registry: @label_registry
        }
      end

      def render
        visit(root)
      end

      def visit(node)
        short_name = node.class.to_s.split('::').last.downcase
        method_name = "visit_#{short_name}"
        # puts "---- #{method_name}"
        # puts node.inspect
        send(method_name, node)
      end

      def visit_expression(node)
        segments = node.segments.map { |segment| visit(segment) }
        segments.last.gsub!(/\.$/, '') # Make the last period optional? Maybe?
        segments.unshift "^"           # Add a bol matcher to the front.
        segments.push "\\.?$"          # Make the last period optional? Again?
        Regexp.new(segments.join)
      end

      def visit_capturesegment(node)
        value = case node.type
        when :integer then /(?<#{node.var_name}>[\d,]+\d*)/    # No decimal
        when :float   then /(?<#{node.var_name}>[\d,]+\.\d+)/  # Decimal point required
        when :numeric then /(?<#{node.var_name}>[\d,]+\.?\d*)/ # Optional decimal
        when :string  then /(?<#{node.var_name}>.*?)/
        when :node    then /(?<#{node.var_name}>.*?)/
        else
          raise ArgumentError, "No regexp pattern for type \"#{node.type}\"."
        end
        # Add type to type registry
        @type_registry[node.var_name] = node.type
        # Add label to label registry
        @label_registry[node.var_name] = node.label if node.type == :node
        return value
      end

      def visit_bare(node)
        visit(node.content)
      end

      def visit_content(node)
        node.content
      end

    end
  end
end
