module Aspen
  class Parser

=begin

  narrative = statements;
  statements = { statement }
  statement = vanilla_statement | list_statement | CUSTOM_STATEMENT
  vanilla_statement = node | node, edge, node, { END_STATEMENT }
  node = node_short_form | node_grouped_form | node_cypher_form
  node_short_form = OPEN_PARENS, CONTENT, CLOSE_PARENS
  node_grouped_form = OPEN_PARENS, { CONTENT, [COMMA] }, CLOSE_PARENS
  node_cypher_form = OPEN_PARENS, LABEL, OPEN_BRACES, { IDENTIFIER, literal, [COMMA] }, CLOSE_BRACES
  literal = STRING | NUMBER
  edge = OPEN_BRACKETS, CONTENT, CLOSE_BRACKETS
  list_statement = node, edge, LABEL, START_LIST, list_items
  list_items = { BULLET, [ node_labeled_form ] }, END_LIST
  node_labeled_form = CONTENT, OPEN_PARENS, CONTENT, CLOSE_PARENS

=end

    def self.parse(tokens, env={})
      new(tokens, env={}).parse
    end

    # Convenience method
    def self.parse_code(code, env={})
      tokens = Aspen::Lexer.tokenize(code, env={})
      parse(tokens, env={})
    end

    attr_reader :tokens, :position

    def initialize(tokens, env={})
      @tokens = tokens
      # Nothing is done with environment in the parser.
      # Calling #next will start at 0
      @position = 0
    end

    def parse
      Aspen::AST::Nodes::Narrative.new(parse_statements)
    end

    alias_method :parse_narrative, :parse

    def parse_statements
      # puts "----> #parse_statements"
      results = []

      # Make sure this returns on empty
      while result = parse_statement
        results << result
        break if tokens[position].nil?
      end

      results
    end

    def parse_statement
      # puts "----> #parse_statement"
      parse_comment ||
      parse_custom_statement ||
      parse_vanilla_statement ||
      parse_list_statement
    end

    def parse_comment
      if comment = expect(:COMMENT)
        puts comment.first.last
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

    def parse_vanilla_statement
      # puts "----> #parse_vanilla_statement"
      # TODO: Might benefit from a condition when doing non-vanilla statements?
      origin = parse_node
      edge   = parse_edge
      dest   = parse_node

      # SMELL: Nil check
      advance if peek && peek.first == :END_STATEMENT

      Aspen::AST::Nodes::Statement.new(origin: origin, edge: edge, dest: dest)
    end

    def parse_node
      # puts "----> #parse_node"
      # parse_node_cypher_form ||
      parse_node_grouped_form || parse_node_short_form
    end

    def parse_node_short_form
      # puts "----> #parse_node_short_form"
      # Terminal instructions require a "need"
      _, content, _ = need(:OPEN_PARENS, :CONTENT, :CLOSE_PARENS)
      Aspen::AST::Nodes::Node.new(
        attribute: content.last,
        label: nil
      )
    end

    def parse_node_grouped_form
      # puts "----> #parse_node_grouped_form with #{[peek] + peek(4)}"
      if (_, label, sep, content, _ = expect(:OPEN_PARENS, :LABEL, :SEPARATOR, :CONTENT, :CLOSE_PARENS))
        Aspen::AST::Nodes::Node.new(
          attribute: content.last,
          label: label.last
        )
      end
    end

    # This complicates things greatly. Can we skip this for now,
    # by rewriting the tests to get rid of this case, and come back to it?
    def parse_node_cypher_form
      # puts "----> #parse_node_cypher_form"
      if (_, label, _, content, _ = expect(:OPEN_PARENS, :CONTENT, :SEPARATOR, :CONTENT, :CLOSE_PARENS))
        Aspen::AST::Nodes::Node.new(content: content.last, label: label.last)
      end
    end

    def parse_literal
      raise NotImplementedError, "#parse_literal not yet implemented"
    end

    def parse_edge
      # puts "----> #parse_edge"
      if (_, content, _ = expect(:OPEN_BRACKETS, :CONTENT, :CLOSE_BRACKETS))
        Aspen::AST::Nodes::Edge.new(content.last)
      end
    end

    def parse_list_statement
      raise NotImplementedError, "#parse_list_statement not yet implemented"
    end

    def parse_list_items
      raise NotImplementedError, "#parse_list_items not yet implemented"
    end

    def parse_node_labeled_form
      raise NotImplementedError, "#parse_node_labeled_form not yet implemented"
    end

    def expect(*expected_tokens)
      upcoming = tokens[position, expected_tokens.size]

      if upcoming.map(&:first) == expected_tokens
        advance_by expected_tokens.size
        upcoming
      end
    end

    def need(*required_tokens)
      upcoming = tokens[position, required_tokens.size]
      expect(*required_tokens) or raise Aspen::ParseError, <<~ERROR
        Unexpected tokens. Expected #{required_tokens.inspect} but got #{upcoming.inspect}
      ERROR
    end

    def first
      tokens.first
    end

    def last
      tokens.last
    end

    def next_token
      t = tokens[position]
      advance
      return t
    end

    def peek(offset = 0)
      if offset > 0
        tokens[position + 1..position + offset]
      else
        tokens[position]
      end
    end

    private

    def advance
      advance_by 1
    end

    def advance_by(offset = 1)
      @position += offset
    end

  end
end


