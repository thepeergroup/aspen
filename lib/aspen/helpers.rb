module Aspen
  module Helpers
    def node(*args)
      if args.first.is_a? Hash
        h = args.first
        "(#{h.keys.first}: #{h.values.first})"
      else
        "not hash"
        "(#{args.first})"
      end
    end

    def edge(name)
      "[#{name}]"
    end
  end
end
