require 'dry/validation'

module Aspen
  module Contracts
    class DefaultAttributeContract < Dry::Validation::Contract

      LABEL = /^[A-Z]{1}\w+$/
      ATTR_NAME = /^[a-z]{1}[a-z_]*[a-z]{1}$/

      schema do
        required(:label).value(:string)
        required(:attr_name).value(:string)
      end

      rule(:label) do
        unless LABEL.match?(value)
          key.failure("must be a valid Neo4j label (one TitleCase word), was #{value}")
        end
      end

      rule(:attr_name) do
        unless ATTR_NAME.match?(value)
          key.failure("must be a single token in snake_case (lowercase and underscores only), was: #{value}")
        end
      end

    end
  end
end
