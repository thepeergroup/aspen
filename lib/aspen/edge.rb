module Aspen
  class Edge

    def initialize(word: , reciprocal: false)
      @word = word
      @reciprocal = reciprocal
    end

    def label
      @word
    end

    def to_cypher
      "-[:#{label.parameterize.underscore.upcase}]-#{cap}"
    end

    private

    def cap
      @reciprocal ? "" : ">"
    end
  end

end
