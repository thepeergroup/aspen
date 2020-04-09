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
      Discourse.from_env(@environment)
    end

    def visit(node)
      short_name = node.class.to_s.split('::').last.downcase
      send("visit_#{short_name}", node)
    end

    def visit_narrative(node)
      statements = node.statements.map { |statement| visit(statement) }
      nodes = statements.flat_map(&:nodes).uniq.map(&:to_cypher)
      edges = statements.flat_map(&:relationship_cypher)
      return [nodes, "\n\n", edges, "\n;\n"].join()
    end

    def visit_statement(node)
      # Process statement nodes
    end

    def visit_node(node)
      Aspen::Node.from_ast(node, discourse)
    end

    def visit_edge(node)
      # Process edge nodes
    end

    def visit_content(node)
      node.content
    end
  end
end
