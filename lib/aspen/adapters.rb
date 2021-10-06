module Aspen
  module Adapters

    class Adapter
      attr_reader :id, :name, :ext, :renderer

      def initialize(id: , name: , ext: )
        @id   = id
        @name = name
        @ext  = ext
        # @todo This will be buggy if we have a two-word class
        @renderer = Kernel.const_get("Aspen::Renderers::#{@name.downcase.capitalize}Renderer")
      end
    end

    class Registry

      attr_reader :data

      def initialize
        @data ||= {
          cypher: Adapter.new(id: :cypher, name: "Cypher", ext: '.cql' ),
          json:   Adapter.new(id: :json,   name: "JSON",   ext: '.json'),
          gexf:   Adapter.new(id: :gexf,   name: "GEXF",   ext: '.gexf'),
        }
        Aspen.available_formats = @data.keys
      end

      def self.get(key)
        # @todo There's a better design for this.
        @@store ||= new.data
        @@store.fetch(key)
      end

    end

  end
end
