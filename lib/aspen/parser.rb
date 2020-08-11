require 'active_support/inflector'

module Aspen
  class Parser < AbstractParser

=begin

  narrative = statements;
  statements = { statement }
  statement = COMMENT | CUSTOM_STATEMENT | list_statement | vanilla_statement
  # Variant 1. TODO: Variant 2
  list_statement = node, edge, LABEL, START_LIST, list_items, END_LIST
  list_items = { list_item }
  list_item = BULLET, CONTENT
  vanilla_statement = node | node, edge, node, { END_STATEMENT }
  node = node_short_form | node_grouped_form | node_cypher_form
  node_short_form = OPEN_PARENS, CONTENT, CLOSE_PARENS
  node_grouped_form = OPEN_PARENS, { CONTENT, [ COMMA ] }, CLOSE_PARENS
  node_cypher_form = OPEN_PARENS, LABEL, OPEN_BRACES, { IDENTIFIER, literal, [ COMMA ] }, CLOSE_BRACES
  literal = STRING | NUMBER
  edge = OPEN_BRACKETS, CONTENT, CLOSE_BRACKETS

=end

    def parse
      Aspen::AST::Nodes::Narrative.new(parse_statements)
    end

    alias_method :parse_narrative, :parse

    def parse_statements
      results = []

      # Make sure this returns on empty
      while result = parse_statement
        results.push(*result)
        break if tokens[position].nil?
      end

      results
    end

    def parse_statement
      parse_comment           ||
      parse_custom_statement  ||
      parse_list_statement    ||
      parse_vanilla_statement
    end

    def parse_comment
      if comment = expect(:COMMENT)
        Aspen::AST::Nodes::Comment.new(comment.first.last)
      end
    end

    def parse_custom_statement
      if content = expect(:CUSTOM_GRAMMAR_STATEMENT)
        # FIXME: Why does this need a #first and a #last?
        # Seems unnecessarily nested. Maybe this happened in the lexer.
        Aspen::AST::Nodes::CustomStatement.new(content.first.last)
      end
    end

    def parse_list_statement
      if expect(:PREPARE_START_LIST)
        origin = parse_node
        edge   = parse_edge
        _, plural_label, _  = need(:OPEN_PARENS, :CONTENT, :CLOSE_PARENS)
        # If singularizing should be conditional, we need to introduce the env in the parser.
        label = plural_label.last.singularize
        # puts "LABEL: #{label.inspect}"
        targets = parse_list_items
        expect(:END_LIST)
        targets.map do |target|
          # puts "TARGET #{target.attribute.content.inner_content} had label #{target.label.content.inner_content.inspect}"
          target.label = label if target.label.content.inner_content.nil?
          # puts "TARGET #{target.attribute.content.inner_content} has label #{target.label.content.inner_content.inspect}"
          Aspen::AST::Nodes::Statement.new(origin: origin, edge: edge, dest: target)
        end
      end
    end

    def parse_list_items
      if need(:START_LIST)
        results = []
        while target = parse_list_item
          results << target
        end
        results
      end
    end

    def parse_list_item
      if (_, content = expect(:BULLET, :CONTENT))
        Aspen::AST::Nodes::Node.new(attribute: content.last)
      end
    end

    def parse_node_labeled_form
      raise NotImplementedError, "#parse_node_labeled_form not yet implemented"
    end

    def parse_vanilla_statement
      # TODO: Might benefit from a condition when doing non-vanilla statements?
      origin = parse_node
      edge   = parse_edge
      dest   = parse_node

      # SMELL: Nil check
      advance if peek && peek.first == :END_STATEMENT

      Aspen::AST::Nodes::Statement.new(origin: origin, edge: edge, dest: dest)
    end

    def parse_node
      # parse_node_cypher_form ||
      parse_node_grouped_form || parse_node_short_form
    end

    def parse_node_grouped_form
      if (_, label, sep, content, _ = expect(:OPEN_PARENS, :LABEL, :SEPARATOR, :CONTENT, :CLOSE_PARENS))
        Aspen::AST::Nodes::Node.new(
          attribute: content.last,
          label: label.last
        )
      end
    end

    def parse_node_short_form
      # Terminal instructions require a "need"
      _, content, _ = need(:OPEN_PARENS, :CONTENT, :CLOSE_PARENS)
      Aspen::AST::Nodes::Node.new(
        attribute: content.last,
        label: nil
      )
    end

    # This complicates things greatly. Can we skip this for now,
    # by rewriting the tests to get rid of this case, and come back to it?
    def parse_node_cypher_form
      if (_, label, _, content, _ = expect(:OPEN_PARENS, :CONTENT, :SEPARATOR, :CONTENT, :CLOSE_PARENS))
        Aspen::AST::Nodes::Node.new(content: content.last, label: label.last)
      end
    end

    def parse_literal
      raise NotImplementedError, "#parse_literal not yet implemented"
    end

    def parse_edge
      if (_, content, _ = expect(:OPEN_BRACKETS, :CONTENT, :CLOSE_BRACKETS))
        Aspen::AST::Nodes::Edge.new(content.last)
      end
    end

    # private

    # def guard(condition)
    #   return false unless condition
    # end

  end
end
