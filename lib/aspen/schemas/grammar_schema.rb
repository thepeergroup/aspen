require 'dry/schema'

=begin

  grammar:
    -
      match:
        - (Person a) knows (Person b).
      template: {{{a}}}-[:KNOWS]->{{{b}}}.

=end

module Aspen
  module Schemas

    GrammarSchema = Dry::Schema.Params do
      # There's an issue with dry/schema when we turn this on.
      # config.validate_keys = true

      required(:match).array(:str?)
      required(:template).filled(:string)
    end

  end
end
