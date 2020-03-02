module Aspen
  module Contracts
    class StatementContract < Dry::Validation::Contract

      params do
        required(:origin) # .filled(:string)
        required(:destination) # .value(:integer)
        required(:edge)
      end

      rule(:origin) do
        # TODO
      end

      rule(:destination) do
        # TODO
      end

      rule(:edge) do
        # TODO
      end

    end
  end
end
