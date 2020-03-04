require "bundler/setup"
require "dry/cli"
require "dry/cli/utils/files"

require "aspen"

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

        example [
          "path/to/file.aspen # Compiles to path/to/file.cypher"
        ]

        def call(path: )
          basename = File.basename(path, ".aspen")
          dir = File.dirname(path)
          dest = File.expand_path("#{basename}.cql", dir)
          File.open(dest, 'w') do |file|
            file << Aspen.compile_text(File.read(path))
          end

          puts "Compiled #{basename}.aspen to #{basename}.cql."
        end
      end

      # module Server
      #   class Start < Dry::CLI::Command
      #     desc "Start Aspen server in the background"

      #     argument :root, required: true, desc: "Root directory"

      #     example [
      #       "path/to/root # Start Aspen at root directory"
      #     ]

      #     def call(root:, **)
      #       puts "started - root: #{root}"
      #     end
      #   end

      #   class Stop < Dry::CLI::Command
      #     desc "Stop Aspen server"

      #     option :graceful, type: :boolean, default: true, desc: "Graceful stop"

      #     def call(**options)
      #       puts "stopped - graceful: #{options.fetch(:graceful)}"
      #     end
      #   end

      #   class Run < Dry::CLI::Command
      #     desc "Run Aspen server in the foreground"

      #     argument :task, type: :string, required: true,  desc: "Task to be executed"
      #     argument :dirs, type: :array,  required: false, desc: "Optional directories"

      #     def call(task:, dirs: [], **)
      #       puts "exec - task: #{task}, dirs: #{dirs.inspect}"
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
      #     desc "Generate tests"

      #     option :framework, default: "minitest", values: %w[minitest rspec]

      #     def call(framework:, **)
      #       puts "generated tests - framework: #{framework}"
      #     end
      #   end

      #   class Narrative < Dry::CLI::Command
      #     desc "Generate tests"

      #     option :framework, default: "minitest", values: %w[minitest rspec]

      #     def call(framework:, **)
      #       puts "generated tests - framework: #{framework}"
      #     end
      #   end
      # end

      register "version", Version, aliases: ["v", "-v", "--version"]
      register "compile", Compile, aliases: ["c"]

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
