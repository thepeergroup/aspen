module Aspen
  module Actions
    class Compile

      attr_reader :options

      def initialize(path, options = {})
        @path = path
        @basename = File.basename(@path, ".aspen")
        dir       = File.dirname(@path)
        @dest     = File.expand_path("#{@basename}.cql", dir)
        @options  = options
      end

      def call
        compile_to_file
        send_to_database if options.fetch(:database, false)
      end

      private

      def compile_to_file
        @cypher ||= Aspen.compile_text(File.read(@path))
        File.open(@dest, 'w') { |file| file << @cypher }
        puts "Compiled #{@basename}.aspen to #{@basename}.cql."
      end

    end
  end
end

