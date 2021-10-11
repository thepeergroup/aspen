require 'csv'
require 'aspen/cli/commands/build_steps'

module Aspen
  module CLI
    module Commands

      # TODO Refactor build into Build::Steps
      # Build Steps should always have access to the manifest and config.
      # Each should have some kind of return and if it's false, throws an error
      # and stops the build.
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
      end # / Build

    end
  end
end
