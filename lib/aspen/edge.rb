module Aspen
  class Edge

    def initialize(word, context)
      @word = word
      @context = context
    end

    def text
      @word.match(Aspen::Statement::EDGE).captures.first
    end

    def reciprocal?
      @context.reciprocal? text
    rescue Aspen::DiscourseError
      false
    end

    def to_cypher
      str = "[:#{text.parameterize.underscore.upcase}]"
      if reciprocal?
        "-#{str}-"
      else
        "-#{str}->"
      end
    end
  end

end
