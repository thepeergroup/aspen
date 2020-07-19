module Aspen
  class Edge

    def initialize(word: , reciprocal: false)
      @word = word
      @reciprocal = reciprocal
    end

    def to_cypher
      "-[:#{@word.parameterize.underscore.upcase}]-#{cap}"
    end

    private

    def cap
      @reciprocal ? "" : ">"
    end
  end

end
