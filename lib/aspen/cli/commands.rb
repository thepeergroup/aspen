require 'aspen/cli/commands/version'
require 'aspen/cli/commands/compile'
require 'aspen/cli/commands/new'
require 'aspen/cli/commands/push'
# require 'aspen/cli/commands/watch'
require 'aspen/cli/commands/build'

module Aspen
  module CLI
    module Commands
      extend Dry::CLI::Registry

      register "version", Version, aliases: ["v", "-v", "--version"]
      register "compile", Compile, aliases: ["c"]
      register "build",   Build,   aliases: ["b"]
      register "push",    Push,    aliases: ["p"]

      # register "watch", Watch::Run, aliases: ["w"]

      register "new", New

      # register "generate", aliases: ["g"] do |prefix|
      #   prefix.register "discourse", Generate::Discourse
      #   prefix.register "narrative", Generate::Narrative
      # end
    end
  end
end
