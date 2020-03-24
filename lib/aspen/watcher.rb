require 'listen'

module Aspen
  class Watcher

    def initialize(path: , options: {})
      @path     = path
      @logger   = options.fetch(:logger) { Logger.new("aspen-watch.log") }
      @database = options.fetch (:database) { false }
      @drop = options.fetch (:drop) { false }
    end

    def start
      Listen.logger = @logger
      listener = Listen.to(@path, only: /\.aspen$/) do |mod, add, _rem|
        files_to_compile = [mod, add].flatten
        files_to_compile.each do |path|
          @logger.info "----> Compiling #{path} ..."
          Aspen::CLI::Commands::Compile.new.call(path: path, database: @database, drop: @drop)
          @logger.info "compiled!"
        end
      end
      listener.start
      puts "Listening to #{@path}..."
      puts "Publishing to database at #{@database}..." if @database
      puts drop_mode_message if @drop
      sleep
    rescue Aspen::Error => e
      puts e.message
      listener.start
    rescue Interrupt => e
      @logger.info "Exiting..."
      puts "Exiting..."
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

