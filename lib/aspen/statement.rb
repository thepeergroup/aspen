module Aspen

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

    def to_cypher
      [
        origin.nickname_node,
        edge.to_cypher,
        destination.nickname_node
      ].join('')
    end

    def self.from_text(line, context: )
      tags = []
      tokens_for(line).each { |token| tags << tag_token(token) }

      nodes = tags.select { |tw| tw.first == :STATEMENT_NODE }
      edges = tags.select { |tw| tw.first == :STATEMENT_EDGE }

      assert_node_count(nodes, line)
      assert_edge_count(edges, line)

      build_statement(nodes, edges, context)
    end

    def self.build_statement(nodes, edges, context)
      new(
        origin:      Node.from_text(nodes.first.last, context),
        destination: Node.from_text(nodes.last.last,  context),
        edge:        Edge.new(edges.first.last, context)
      )
    end

    def self.tag_token(token)
      case token
      when NODE
        [:STATEMENT_NODE, token]
      when EDGE
        [:STATEMENT_EDGE, token]
      when PERIOD
        [:PERIOD]
      else
        raise Aspen::TagError, Aspen::Error.messages(:no_statement_tag, token, line)
      end
    end

    def self.assert_node_count(nodes, line)
      unless nodes.count == 2
        raise Aspen::StatementError,
          Aspen::Errors.messages(:statement_node_count, nodes, line)
      end
    end

    def self.assert_edge_count(edges, line)
      unless edges.count == 1
        raise Aspen::StatementError,
          Aspen::Errors.messages(:statement_edge_count, edges, line)
      end
    end

    def self.tokens_for(text)
      text.scan(NODES_AND_EDGES).flatten.compact
    end

  end
end
