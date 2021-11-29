module Aspen
  class Edge

    # @todo Rename :word to :label
    def initialize(name, mutual: false)
      @name = name
      @mutual = mutual
    end

    def label
      @name
    end

    def to_cypher
      "-[:#{label.parameterize.underscore.upcase}]-#{cap}"
    end

    def signature
      to_cypher.gsub(/:/, '')
    end

    def mutual?
      @mutual
    end

    alias_method :reciprocal?, :mutual?

    private

    def cap
      @mutual ? "" : ">"
    end
  end

end
