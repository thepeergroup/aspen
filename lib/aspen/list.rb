module Aspen
  class List

    REGEX = /\s*,?\s*and\s*/i

    def initialize(array = [])
      @elements = Array(array)
    end

    def self.from_text(text)
      new text.
            gsub(REGEX, ', ').
            split(',').
            map(&:strip)

    end
  end
end

