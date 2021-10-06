require 'listen'

module Aspen
  module Actions
    class Watch

      def initialize(options: {})
        @options = options
        @logger  = options.fetch(:logger) { Logger.new(STDOUT, level: :warn) }
        Listen.logger = @logger
      end

      def call
        puts warning_message if using_database?

        listener = Listen.to('src/', only: /\.aspen$/) do |mod, add, _rem|
          Aspen::CLI::Commands::Build.new.call
          Aspen::Actions::Push.new.call
        rescue Aspen::Error => e
          puts e.message
        end

        listener.start
        sleep
      rescue Interrupt => e
        # FIXME: The logger calls don't ever seem to work.
        @logger.info "Exiting..."
        puts "\nExiting..."
        listener.stop
        raise SystemExit
      end

      private

        def using_database?
          @options[:database]
        end

        def warning_message
          <<~MSG
            ⚠️ WARNING: `aspen watch` is experimental, and saving a file/rebuilding the data
            will cause ALL OF THE DATA in the database to be DELETED and rewritten.

            By proceeding, you acknowledge that the Neo4j database at TODO: host:port will
            be dropped the next time a file in this project is saved.

            Use Ctrl+C to quit.

            Watching....
          MSG
        end

    end
  end
end
