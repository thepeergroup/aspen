module Aspen
  class Edge

    # @todo Rename :word to :label
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

    def signature
      to_cypher.gsub(/:/, '')
    end

    def reciprocal?
      @reciprocal
    end

    private

    def cap
      @reciprocal ? "" : ">"
    end
  end

end
