module Aspen
  module CLI
    module Commands

      class Version < Dry::CLI::Command
        desc "Print version"

        def call(*)
          puts Aspen::VERSION
        end
      end

    end
  end
end
