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
      @adapter = environment.fetch(:adapter, :cypher).to_sym
      # FIXME: This is too much responsibility for the compiler.
      @slug_counters = Hash.new { 1 }

      unless Aspen.available_formats.include?(@adapter)
        raise Aspen::ArgumentError, <<~MSG
          The adapter, also known as the output format, must be one of:
          #{Aspen.available_formats.join(', ')}.

          What Aspen received was #{@adapter}.
        MSG
      end
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

      renderer_klass = Kernel.const_get("Aspen::Renderers::#{@adapter.to_s.downcase.capitalize}Renderer")
      renderer_klass.new(statements).render
    end

    def visit_statement(node)
      Statement.new(
        origin: visit(node.origin),
        edge: visit(node.edge),
        destination: visit(node.destination)
      )
    end

    # TODO: When you pick up, get the labels back into here.
    #   Labelreg? typereg[:labels]?
    # FIXME: This is doing too much.
    # IDEA: Can't we have typed attributes come from the Grammar?
    def visit_customstatement(node)
      statement = visit(node.content)
      matcher   = discourse.grammar.matcher_for(statement)
      results   = matcher.captures(statement)
      template  = matcher.template
      typereg   = matcher.typereg
      labelreg  = matcher.labelreg

      nodes = []

      typed_results = results.inject({}) do |hash, elem|
        key, value = elem
        typed_value = case typereg[key]
        when :integer then value.to_i
        when :float   then value.to_f
        when :numeric then
          value.match?(/\./) ? value.to_f : value.to_i
        when :string  then "\"#{value}\""
        when :node    then
          # FIXME: This only handles short form.
          #   I think we were allowing grouped and Cypher form to fill
          #   in custom statement templates.
          # TODO: Add some object to nodes array.
          node = visit(
            Aspen::AST::Nodes::Node.new(
              attribute: value,
              label: labelreg[key]
            )
          )
          nodes << node
          node
        end
        hash[key] = typed_value
        hash
      end

      formatted_results = typed_results.inject({}) do |hash, elem|
        key, value = elem
        formatted_value = if value.is_a?(Aspen::Node)
          value.nickname_node
        else
          value
        end
        hash[key] = formatted_value

        # TODO: Trying to insert a p_id as well as p to be used in JSON identifiers.
        # if value.is_a?(Aspen::Node)
        #   hash["#{key}_id"] = value.nickname
        # end
        # puts "TYPED VALS: #{hash.inspect}"
        hash
      end

      slugs = template.scan(/{{{?(?<full>uniq_(?<name>\w+))}}}?/).uniq
      usable_results = if slugs.any?
        counts = slugs.map do |full, short|
          [full, "#{short}_#{@slug_counters[full]}"]
        end.to_h

        context = results.merge(counts)
        custom_statement = CustomStatement.new(
          nodes: nodes,
          cypher: Mustache.render(template.strip, formatted_results.merge(counts))
        )
        slugs.each do |full, _|
          @slug_counters[full] = @slug_counters[full] + 1
        end
        custom_statement
      else
        CustomStatement.new(
          nodes: nodes,
          cypher: Mustache.render(template.strip, formatted_results)
        )
      end
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
      content = visit(node.content)
      unless discourse.allows_edge?(content)
        raise Aspen::Error, """
          Your narrative includes an edge called '#{content}',
          but only #{discourse.allowed_edges} are allowed.
        """
      end
      Aspen::Edge.new(
        word: content,
        reciprocal: discourse.reciprocal?(visit(node.content))
      )
    end

    def visit_label(node)
      content = visit(node.content)
      label = Maybe(content).value_or(discourse.default_label)
      unless discourse.allows_label?(label)
        raise Aspen::CompileError, """
          Your narrative includes a node with label '#{label}',
          but only #{discourse.allowed_labels} are allowed.
        """
      end
      label
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
      node.content
    end

    def visit_comment(node)
      # Signal to other methods to reject comments.
      :comment
    end
  end
end
