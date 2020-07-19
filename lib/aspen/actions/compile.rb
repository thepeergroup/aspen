require 'neo4j/core'
require 'neo4j/core/cypher_session/adaptors/http'

module Aspen
  module Actions
    class Compile

      attr_reader :options

      def initialize(path, options = {})
        @path = path
        @basename = File.basename(@path, ".aspen")
        dir       = File.dirname(@path)
        @dest     = File.expand_path("#{@basename}.cql", dir)
        @options  = options
      end

      def call
        compile_to_file
        send_to_database if options.fetch(:database, false)
      end

      private

      def cypher
        @cypher ||= Aspen.compile_text(File.read(@path))
      end

      def compile_to_file
        File.open(@dest, 'w') { |file| file << cypher }
        puts "Compiled #{@basename}.aspen to #{@basename}.cql."
      end

      def send_to_database
        db_drop if options.fetch(:drop)
        db_push
      end

      def db
        return @session if @session
        url = options.fetch(:database)
        puts "About to push to Neo4j at #{url}"
        adaptor = Neo4j::Core::CypherSession::Adaptors::HTTP.new(url, {})
        @session = Neo4j::Core::CypherSession.new(adaptor)
      end

      def db_drop
        print "About to drop data from database..."
        db.query("MATCH (n) DETACH DELETE n")
        print "OK\n"
      end

      def db_push
        print "About to push data to database..."
        db.query(cypher)
        print "OK\n"
      end

    end
  end
end

