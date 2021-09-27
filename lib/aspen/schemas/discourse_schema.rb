=begin

  Example:

  default:
    label:     Person
    attribute: name (text)
    attributes:
      Event:   title (text)
      Company: year_founded (number)

  only:
    nodes: Person, Company
    relationships: knows, works for

  reciprocal: knows

  grammar:
    -
      match: (Person a) knows (Person b).
      template: {{{a}}}-[:KNOWS]->{{{b}}}.

=end

require 'dry/schema'
require 'aspen/schemas/grammar_schema'

module Aspen
  module Schemas

    LABEL      = /^([A-Z][A-Za-z0-9]+)+$/
    LABEL_LIST = /^([A-Z][A-Za-z0-9]+)(,\s*([A-Z][A-Za-z0-9]+))*$/
    EDGE_LIST  = /^([A-Za-z\s]+)(,\s*[A-Za-z\s]+)*$/
    IDENT      = /^[A-Za-z]\w*$/
    IDENT_LIST = /^(\w+)(,\s*\w+)*$/

    DiscourseSchema = Dry::Schema.Params do
      # config.validate_keys = true

      optional(:adapter)

      optional(:default).hash do
        optional(:label).filled(:string, format?: LABEL)
        optional(:attribute).filled(:string, format?: IDENT)
        optional(:attributes).filled(:hash) # TODO Validate hash
      end

      optional(:allow_only).hash do
        optional(:nodes).filled
        optional(:edges).filled
      end

      # TODO Validate that there are no reciprocal relationships
      # not listed in `only`
      # Is there a way to do something like:
      #   included_in?: [ self.only ] if self.only
      # Yes! If we make this a validation!
      optional(:reciprocal).filled(:string, format?: EDGE_LIST)

      optional(:grammar).array(GrammarSchema)
    end

  end
end
