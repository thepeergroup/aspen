module Aspen
  class Body

    attr_reader :tags

    def initialize(text, context: )
      @text = text
      @context = context
      tag_lines
      process_lines
    end

    def tag_lines
      @tags = []
      @text.lines.
        each { |line| @tags << tag_line(line.strip) }
      @tags
    end

    def tag_line(line)
      if @context.grammar.match?(line)
        [:STATEMENT_CUSTOM_GRAMMAR, line]
      else
        case line
        when /^\s*$/
          [:EMPTY_LINE]
        when /^\(/
          [:STATEMENT_DEFAULT_GRAMMAR, line]
        else
          raise Aspen::BodyError,
            Aspen::Errors.messages(:no_body_tag, line, @context.grammar)
        end
      end
    end

    def process_lines
      @statements = []
      @tags.map do |tagged_line|
        tag, arg = tagged_line
        @statements << case tag
        when :EMPTY_LINE
          next
        when :STATEMENT_CUSTOM_GRAMMAR
          CustomStatement.from_text(arg, context: @context)
        when :STATEMENT_DEFAULT_GRAMMAR
          Statement.from_text(arg, context: @context)
        end
      end
    end

    def to_cypher
      node_statements = @statements.flat_map(&:nodes).map { |n| "MERGE #{n.to_cypher}" }.uniq.join("\n")
      edge_statements = @statements.
        flat_map { |s| s.to_cypher.split("\n") }.
        map      { |c| "MERGE #{c}" }.
        join("\n")

      return [node_statements, "\n\n", edge_statements, "\n;\n"].join("")
    end

  end
end
