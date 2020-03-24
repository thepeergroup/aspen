require 'bundler/setup'
require 'dry/cli'
require 'dry/cli/utils/files'

require 'listen'
require 'neo4j/core'
require 'neo4j/core/cypher_session/adaptors/http'

require 'aspen'
require 'aspen/watcher'

module Aspen
  module CLI
    module Commands
      extend Dry::CLI::Registry

      class Version < Dry::CLI::Command
        desc "Print version"

        def call(*)
          puts Aspen::VERSION
        end
      end

      class Compile < Dry::CLI::Command
        desc "Compile an Aspen file to Cypher (in the same directory)"

        argument :path, required: true, desc: "Aspen file to compile to Cypher"

        option :database, type: :string, desc: "Database URL", aliases: ["d"]
        # option :mode, default: "http", values: %w[http https bolt], desc: "The connection protocol"

        example [
          "path/to/file.aspen                                      # Compiles to path/to/file.cypher",
          "path/to/file.aspen -d http://neo4j:pass@localhost:11002 # Compiles and runs in database"
        ]

        def call(path: , **options)
          basename = File.basename(path, ".aspen")
          dir = File.dirname(path)
          dest = File.expand_path("#{basename}.cql", dir)
          cypher = Aspen.compile_text(File.read(path))
          File.open(dest, 'w') { |file| file << cypher }

          puts "Compiled #{basename}.aspen to #{basename}.cql."

          if options.fetch(:database) { false }
            url = options.fetch(:database)
            puts "About to push to Neo4j at #{url}"
            adaptor = Neo4j::Core::CypherSession::Adaptors::HTTP.new(url, {})
            session = Neo4j::Core::CypherSession.new(adaptor)
            if options.fetch(:drop)
              print "About to drop data from database..."
              session.query("MATCH (n) DETACH DELETE n")
              print "OK\n"
            end
            print "About to push data to database..."
            res = session.query(cypher) # 'MATCH (n) RETURN n LIMIT 10'
            print "OK\n"
          end
        end
      end

      module Watch
        class Run < Dry::CLI::Command
          desc "Watch a single file and automatically compile it"

          argument :path, required: true, desc: "Folder or file to watch for changes"
          option :database, type: :string, desc: "Database URL", aliases: ["d"]
          option :drop, type: :boolean, desc: "DANGER: Drops db before every push"

          example [
            "folder/with/aspen/                                      # Recompiles files upon changes",
            "folder/with/aspen/ -d http://neo4j:pass@localhost:11002 # Pushes recompiled Cypher to database"
          ]

          def call(path: , **options)
            Aspen::Watcher.new(path: path, options: options).start
          end
        end
      end

      # module Server
      #   class Start < Dry::CLI::Command
      #     desc "Start Aspen server in the background"
      #     def call()
      #       # NO OP
      #     end
      #   end

      #   class Stop < Dry::CLI::Command
      #     desc "Stop Aspen server"
      #     def call()
      #       # NO OP
      #     end
      #   end

      #   class Run < Dry::CLI::Command
      #     desc "Run Aspen server in the foreground"
      #     def call()
      #       # NO OP
      #     end
      #   end
      # end

      class New < Dry::CLI::Command
        desc "Generate files for a new Aspen project"

        argument :name,
          desc: "Name for new Aspen project folder",
          required: true

        def call(name: )
          Dry::CLI::Utils::Files.mkdir(name)
          # This should be re-added only when discourses
          # can be written as a special discourse file.
          # Dry::CLI::Utils::Files.mkdir("#{name}/discourses")
          Dry::CLI::Utils::Files.mkdir("#{name}/narratives")
          Dry::CLI::Utils::Files.touch("#{name}/narratives/#{name}.aspen")

          # In a project, Aspen might be built into a set of Cypher files
          # or perhaps a single master Cypher file.
          Dry::CLI::Utils::Files.mkdir("#{name}/build")

          puts "Generated new project '#{name}'"
        end
      end

      # module Generate
      #   class Discourse < Dry::CLI::Command
      #     desc "Generate a new discourse within a project"
      #     def call()
      #       # NO OP
      #     end
      #   end

      #   class Narrative < Dry::CLI::Command
      #     desc "Generate a new narrative within a project"
      #     def call()
      #       # NO OP
      #     end
      #   end
      # end

      register "version", Version, aliases: ["v", "-v", "--version"]
      register "compile", Compile, aliases: ["c"]

      register "watch", Watch::Run, aliases: ["w"]

      # register "new", New

      # register "generate", aliases: ["g"] do |prefix|
      #   prefix.register "discourse", Generate::Discourse
      #   prefix.register "narrative", Generate::Narrative
      # end

      # register "server", aliases: ["s"] do |prefix|
      #   prefix.register "run",   Server::Run
      #   prefix.register "start", Server::Start
      #   prefix.register "stop",  Server::Stop
      # end
    end
  end
end
