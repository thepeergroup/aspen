require 'listen'

module Aspen
  module Actions
    class Watch

      def initialize(path: , options: {})
        @path     = path
        @logger   = options.fetch(:logger)   { Logger.new(STDOUT, level: :warn) }
        @database = options.fetch(:database) { false }
        @drop     = options.fetch(:drop)     { false }

        Listen.logger = @logger
      end

      def call
        puts "Using debug level #{@logger.level}"
        puts "Listening for changes at path: #{@path.inspect} ..."
        puts "Publishing to database at #{@database}..." if @database
        puts drop_mode_message if @drop
        listener = Listen.to(@path, only: /\.aspen$/) do |mod, add, _rem|
          begin
            files_to_compile = [mod, add].flatten
            files_to_compile.each do |path|
              Aspen::CLI::Commands::Compile.new.call(path: path, database: @database, drop: @drop)
            end
          rescue Aspen::Error => e
            puts e.message
          end
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

      def drop_mode_message
        <<~MSG

          ---- DANGER! DROP MODE!

            You enabled drop mode, which will delete all the contents of your database
            before every compilation.

            If you want to stop this, press Ctrl+C and remove the --drop option,
            or replace it with --no-drop.
        MSG
      end

    end
  end
end
