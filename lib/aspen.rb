require "aspen/version"
require "aspen/configuration"
require "aspen/node"
require "aspen/guards"

module Aspen

  # Potential problems I'm seeing already:
  # - What if they try to do > 2 nodes, > 1 edges?
  # - What if the text includes parentheses? Should we allow escaping?

  def self.compile_text(text)

    config_text, *split_body = text.partition("\n(")
    body = split_body.join().strip()

    config = Configuration.new(config_text)

    node_regex = /\((.*?)\)/
    edge_regex = /\[(.*?)\]/

    # I really don't like this interface.
    # Instead, read every line, read every word, tagging it. Make sure the no-match case raises an error.
    # Make sure open-parens and close-parens match up
    # Pass in tagged words from a single line to a Statement constructor.
    # Check statement validity as you go along.
    # Once all the statements are read, establish the nodes and relationships,
    # Check for attribute uniqueness / do registry things.
    # Then build Cypher
    nodes_text = body.scan(node_regex).map(&:first)
    edge_text  = body.scan(edge_regex).first.first

    nodes = nodes_text.map { |node_text| Node.from_text(node_text, config) }
    edge_string = ":#{edge_text.upcase}"

    <<~CYPHER
      MERGE #{nodes.first.to_s}
      , #{nodes.last.to_s}

      , (#{nodes.first.nickname})-[#{edge_string}]->(#{nodes.last.nickname})
    CYPHER
  end

  class Relationship
    # A valid relationship has exactly two nodes.
    # A valid relationship has exactly one edge.
    #   indicates reciprocality - so it needs to get this from the context/discourse
    # (A class above this might be a statement, which could name many relationships.)
  end

  class ConfigurationError < StandardError ; end

end
