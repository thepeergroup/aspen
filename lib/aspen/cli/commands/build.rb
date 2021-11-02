require 'csv'
require 'aspen/cli/commands/build_steps'

module Aspen
  module CLI
    module Commands

      class Build < Dry::CLI::Command
        desc "Build Aspen project"

        include BuildSteps

        def call(*)
          CheckAspenProject.new.call
          DownloadAttachedResources.new.call
          ConvertIntoAspen.new.call
          main_aspen_file = CollectMainAspen.new.call
          CompileMainAspen.new.call(main_aspen_file)
        end
      end

    end
  end
end
