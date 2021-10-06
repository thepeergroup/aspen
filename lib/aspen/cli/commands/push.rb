module Aspen
  module CLI
    module Commands

      class Push < Dry::CLI::Command
        desc "Push latest Cypher"

        def call(*)
          Aspen::Actions::Push.new.call
        end
      end

    end
  end
end
