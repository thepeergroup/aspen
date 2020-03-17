require 'aspen/version'
require 'aspen/errors'

require 'aspen/configuration'
require 'aspen/node'
require 'aspen/edge'

require 'aspen/statement'
require 'aspen/custom_statement'
require 'aspen/matcher'
require 'aspen/grammar'

require 'aspen/contracts'
require 'aspen/nickname_registry'

module Aspen

  def self.compile_text(text)
    if text.strip.empty?
      raise Aspen::Error, "Text must be provided to the `Aspen.compile_text` method."
    end

    config_text, *split_body = text.partition("\n\n\n")
    body = split_body.join().strip()

    config = Configuration.new(config_text)

    # SMELL: We introduce and remove `nil`s here.
    statements = body.lines.map do |line|
      puts "LINE: #{line}"
      next if line.strip.empty?
      if config.grammar.match?(line)
        CustomStatement.from_text(line, context: config)
      else
        Statement.from_text(line, context: config)
      end
    end.compact

    node_statements = statements.flat_map(&:nodes).map { |n| "MERGE #{n.to_cypher}" }.uniq.join("\n")
    edge_statements = statements.map { |s| "MERGE #{s.to_cypher}" }.join("\n")

    <<~CYPHER
      #{node_statements}

      #{edge_statements}
      ;
    CYPHER
  end

end
