require 'aspen/actions/compile'

module Aspen
  module CLI
    module Commands

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
          Aspen::Actions::Compile.new(path, options).call
        end
      end

    end
  end
end
