require 'neo4j/core'
require 'neo4j/core/cypher_session/adaptors/http'

module Aspen
  module Actions
    class Push

      def initialize(path: nil, config_path: 'config/db.yml')
        @path_to_cql = path || Dir["build/main-*.cql"].first
        config = YAML::load_file(config_path)
        url = config.fetch("url").strip
        adapter = Neo4j::Core::CypherSession::Adaptors::HTTP.new(url, {})
        @session = Neo4j::Core::CypherSession.new(adapter)
      rescue => e
        puts e.message
        puts e.backtrace
      end

      def call
        drop
        push
      end

      def drop
        print "Dropping data from database..."
        @session.query("MATCH (n) DETACH DELETE n")
        print "OK\n"
      end

      def push
        file = File.read(@path_to_cql)
        print "Pushing data to database from #{@path_to_cql}..."
        @session.query(file)
        print "OK\n"
      end

    end
  end
end
