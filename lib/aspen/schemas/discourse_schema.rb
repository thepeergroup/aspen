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

    LABEL = /^([A-Z][A-Za-z0-9]+)+$/
    LABEL_LIST = /^([A-Z][A-Za-z0-9]+)(,\s*([A-Z][A-Za-z0-9]+))*$/
    EDGE_LIST = /^([A-Za-z\s]+)(,\s*[A-Za-z\s]+)*$/
    IDENTIFIER = /^[A-Za-z]\w*$/
    IDENTIFIER_LIST = /^(\w+)(,\s*\w+)*$/

    DiscourseSchema = Dry::Schema.Params do
      # There's an issue with dry/schema when validating keys
      # and you have an array of strings.
      # config.validate_keys = true

      optional(:default).hash do
        optional(:label).filled(:string, format?: LABEL)
        optional(:attribute).filled(:string, format?: IDENTIFIER)
        optional(:attributes).filled(:hash) # TODO Validate hash
      end

      optional(:only).hash do
        optional(:nodes).filled(:string, format?: LABEL_LIST)
        optional(:relationships).filled(:string, format?: EDGE_LIST)
      end

      # TODO Validate that there are no reciprocal relationships
      # Not listed
      optional(:reciprocal).filled(:string, format?: EDGE_LIST)

      optional(:grammar).array(GrammarSchema)
    end

  end
end
