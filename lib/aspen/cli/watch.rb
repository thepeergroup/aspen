require 'aspen/actions/watch'

module Aspen
  module CLI
    module Commands

      module Watch
        class Run < Dry::CLI::Command
          desc "Watch a single file and automatically compile it"

          argument :path,
            type:     :string,
            desc:     "Folder or file to watch for changes",
            default:  "."

          option :database,
            type:    :string,
            desc:    "Database URL",
            aliases: ["d"]

          option :drop,
            type: :boolean,
            desc: "DANGER: Drops db before every push"

          example [
            "folder/with/aspen/                                      # Recompiles files upon changes",
            "folder/with/aspen/ -d http://neo4j:pass@localhost:11002 # Pushes recompiled Cypher to database"
          ]

          def call(path: , **options)
            Aspen::Actions::Watch.new(path: path, options: options).call
          end
        end
      end

    end
  end
end
