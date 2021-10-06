require 'aspen/actions/watch'

module Aspen
  module CLI
    module Commands

      module Watch
        class Run < Dry::CLI::Command
          desc "Watch the project for changes; rebuild and push"

          option :database,
            type:    :boolean,
            default: true,
            desc:    "Push to sandbox database in config/db.yml",
            aliases: ["d"]

          example [
            "   # Recompiles and pushes to database",
            "-D # Only recompiles files",
          ]

          def call(**options)
            Aspen::Actions::Watch.new(options: options).call
          end
        end
      end

    end
  end
end
