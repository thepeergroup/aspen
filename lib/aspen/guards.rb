module Aspen
  module Guards

    # TODO: Replace this module with dry-rb validations, etc.

    SINGLE_WORD = /^(\w+)$/

    def self.assert_simple_token(string, with: ConfigurationError)
      unless string.match?(SINGLE_WORD)
        raise(with)
      end
      return string
    end
  end
end
