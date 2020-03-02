require 'aspen/version'
require 'aspen/configuration'
require 'aspen/node'
require 'aspen/guards'
require 'aspen/contracts'
require 'aspen/statement'
require 'aspen/nickname_registry'

module Aspen

  class ConfigurationError < StandardError ; end
  class Error < StandardError ; end

  # Potential problems I'm seeing already:
  # - What if they try to do > 2 nodes, > 1 edges?
  # - What if the text includes parentheses? Should we allow escaping?

  def self.compile_text(text)

    config_text, *split_body = text.partition("\n(")
    body = split_body.join().strip()

    config = Configuration.new(config_text)

    statements = body.lines.map do |line|
      Statement.from_text(line)
    end

    collected_nodes = statements.flat_map do |statement|
      statement.nodes.map do |node|
        Node.from_text(node.word, config)
      end
    end

    # TODO. Okay, what actually needs to happen is
    # to swap out the nodes WITHIN STATEMENTS with nicknamed nodes.
    nicknamer = NicknameRegistry.new()
    nicknamer.load_nodes(collected_nodes)
    nodes = nicknamer.nicknamed_nodes

    puts nodes.inspect

    edge_string = ":PLACEHOLDER"

    # Cypher Builder will:
    # - take all the statements
    # - select unique nodes (pass a block to uniq), may want to do this
    #   making sure the nodes appear in the same order as they do in statements
    # - If there's an Employer Matt and Person Matt, we need namespace nicknames.
    # - Take all relationships, using the nickname namespace
    node_head, *node_tail = nodes.map(&:to_cypher)

    <<~CYPHER
      MERGE #{node_head}
      , #{node_tail.join(",\n")}

      , (#{nodes.first.nickname})-[#{edge_string}]->(#{nodes.last.nickname})
    CYPHER
  end

  class Relationship
    # A valid relationship has exactly two nodes.
    # A valid relationship has exactly one edge.
    #   indicates reciprocality - so it needs to get this from the context/discourse
    # (A class above this might be a statement, which could name many relationships.)
  end

end
