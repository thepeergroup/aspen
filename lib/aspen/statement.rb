module Aspen

  class TagError < StandardError ; end
  class StatementError < StandardError ; end

  class Statement
    NODE = /(\(.*?\))/
    EDGE = /\[(.*?)\]/
    PERIOD = /\.{1}/

    NODES_AND_EDGES = /(\(.*?\))|(\[.*?\])/

    TaggedWord = Struct.new(:word, :tag)

    attr_reader :origin, :edge, :destination

    def initialize(origin: , edge: , destination: )
      @origin      = origin
      @edge        = edge
      @destination = destination
    end

    def nodes
      [origin, destination]
    end

    def self.from_text(statement_text)
      tagged_words = tokens_for(statement_text).map do |word|
        case word
        when NODE
          TaggedWord.new(word, :node)
        when EDGE
          TaggedWord.new(word, :edge)
        when PERIOD
          # NO OP
        else
          raise Aspen::TagError, "Couldn't figure out how to tag '#{word}'."
        end
      end

      nodes = tagged_words.select { |tw| tw.tag == :node }
      edges = tagged_words.select { |tw| tw.tag == :edge }

      unless nodes.count == 2
        raise Aspen::StatementError, <<~ERROR
          A statement may only have two nodes, but we found #{nodes.count}:
            #{nodes.map(&:word).join(", ")}
          ERROR
      end

      unless edges.count == 1
        raise Aspen::StatementError, <<~ERROR
          A statement may only have two edges, but we found #{edges.count}:
            #{edges.map(&:word).join(", ")}
          ERROR
      end

      new(
        origin: nodes.first,
        destination: nodes.last,
        edge: edges.first
      )
    end

    def self.tokens_for(text)
      text.scan(NODES_AND_EDGES).flatten.compact
    end

  end
end
