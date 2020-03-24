require 'listen'

module Aspen
  class Watcher

    include Dry::Monads[:maybe]

    def initialize(path: , logger: nil)
      @path = path
      @logger = if Maybe(logger).value_or(false)
        logger
      else
        Logger.new("aspen-watch.log")
      end
    end

    def start
      Listen.logger = @logger
      listener = Listen.to(@path, only: /\.aspen$/) do |mod, add, _rem|
        files_to_compile = [mod, add].flatten
        files_to_compile.each do |path|
          @logger.info "----> Compiling #{path} ..."
          Aspen::CLI::Commands::Compile.new.call(path: path)
          @logger.info "compiled!"
        end
      end
      listener.start
      sleep
      rescue Interrupt => e
      @logger.info "Exiting..."
      puts "Exiting..."
      listener.stop
      raise SystemExit
    end

  end
end

