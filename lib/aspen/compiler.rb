require 'dry/monads'
include Dry::Monads[:maybe]

module Aspen
  class Compiler

    attr_reader :root, :environment

    def self.render(root, environment = {})
      new(root, environment).render
    end

    def initialize(root, environment = {})
      @root = root
      @environment = environment
    end

    def render
      visit(root)
    end

    def discourse
      @discourse ||= Discourse.from_hash(@environment)
    end

    def visit(node)
      short_name = node.class.to_s.split('::').last.downcase
      method_name = "visit_#{short_name}"
      # puts "---- #{method_name}"
      # puts node.inspect
      send(method_name, node)
    end

    def visit_narrative(node)
      # Instead of letting comments be `nil` and using `#compact`
      # to silently remove them, possibly hiding errors, we "compile"
      # comments as `:comment` and filter them explicitly
      statements    = node.statements.map do |statement|
        # This will visit both regular and custom statements.
        visit(statement)
      end.reject { |elem| elem == :comment }
      nodes         = format_nodes(statements)
      relationships = format_relationships(statements)
      return [nodes, "\n\n",  relationships, "\n;\n"].join()
    end

    def format_nodes(statements)
      statements.
        flat_map(&:nodes).
        map { |node| "MERGE #{node.to_cypher}" }.
        uniq.
        join("\n")
    end

    def format_relationships(statements)
      statements.
        flat_map(&:to_cypher).
        map { |statement_cypher| "MERGE #{statement_cypher}" }.
        join("\n")
    end

    def visit_statement(node)
      Statement.new(
        origin: visit(node.origin),
        edge: visit(node.edge),
        destination: visit(node.destination)
      )
    end

    def visit_customstatement(node)
      puts node.inspect
      CustomStatement.new(visit(node.content), discourse)
    end

    def visit_node(node)
      # Get the label, falling back to the default label.
      label = visit(node.label)

      # Get the attribute name, falling back to the default attribute name.
      attribute_name  = Maybe(nil).value_or(discourse.default_attr_name(label))
      typed_attribute_value = visit(node.attribute)
      nickname = typed_attribute_value.to_s.downcase

      Aspen::Node.new(
        label: label,
        attributes: { attribute_name => typed_attribute_value }
      )
    end

    def visit_edge(node)
      Aspen::Edge.new(
        word: visit(node.content),
        reciprocal: discourse.reciprocal?(visit(node.content))
      )
    end

    def visit_label(node)
      content = visit(node.content)
      Maybe(content).value_or(discourse.default_label)
    end

    def visit_attribute(node)
      content = visit(node.content)
      type    = visit(node.type)
      content.send(type.converter)
    end

    def visit_type(node)
      node
    end

    def visit_content(node)
      # puts "\t\t#{node.inspect}"
      node.content
    end

    def visit_comment(node)
      # Signal to other methods to reject comments.
      :comment
    end
  end
end
