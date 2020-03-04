require 'aspen/version'

require 'aspen/configuration'
require 'aspen/node'
require 'aspen/edge'
require 'aspen/statement'

require 'aspen/guards'
require 'aspen/contracts'
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

    # I don't like that we introduce and remove nils here.
    statements = body.lines.map do |line|
      next if line.strip.empty?
      Statement.from_text(line, context: config)
    end.compact

    # TODO. Okay, what actually needs to happen is
    # to swap out the nodes WITHIN STATEMENTS with nicknamed nodes.

    # The registry requests all of the statements' nodes. The statements send the nodes.
    #   The registry takes whatever attributes it needs to make decisions.
    #   Are we decorating? Then keeping in-order? Because all of them need the nickname.
    # Then all of the statements.

    # nicknamer = NicknameRegistry.new()
    # nicknamer.load_statements(statements)
    # statements_with_nicknames = nicknamer.nicknamed_statements

    # Cypher Builder will:
    # - take all the statements
    # - select unique nodes (pass a block to uniq), may want to do this
    #   making sure the nodes appear in the same order as they do in statements
    # - If there's an Employer Matt and Person Matt, we need namespace nicknames.
    # - Take all relationships, using the nickname namespace
    node_statements = statements.flat_map(&:nodes).map { |n| "MERGE #{n.to_cypher}" }.uniq.join("\n")
    edge_statements = statements.map { |s| "MERGE #{s.to_cypher}" }.join("\n")

    <<~CYPHER
      #{node_statements}

      #{edge_statements}
      ;
    CYPHER
  end

  class Relationship
    # A valid relationship has exactly two nodes.
    # A valid relationship has exactly one edge.
    #   indicates reciprocality - so it needs to get this from the context/discourse
    # (A class above this might be a statement, which could name many relationships.)
  end

end
