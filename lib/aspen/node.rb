require 'active_support/core_ext/string/inflections'
require 'aspen/statement'

module Aspen
  class Node

    extend Dry::Monads[:maybe]

    attr_reader :label, :attributes, :nickname
    attr_writer :nickname

    def initialize(label: , attributes: {})
      @label      = label
      @attributes = attributes
      @nickname   = nickname_from_first_attr_value
    end

    def nickname_from_first_attr_value
      "#{@label}-#{@attributes.values.first}".parameterize.underscore
    end

    def to_cypher
      if nickname
        "(#{nickname}:#{label} #{ attribute_string })"
      else
        "(#{label} #{ attribute_string })"
      end
    end

    def nickname_node
      "(#{nickname})"
    end

    def attribute_string
      attributes.to_s.
        gsub(/"(?<token>[[:alpha:]_]+)"=>/, '\k<token>: ').
        # This puts a single space inside curly braces.
        gsub(/\{(\s*)/, "{ ").
        gsub(/(\s*)\}/, " }")
    end

    def ==(other)
      label      == other.label &&
      attributes == other.attributes &&
      nickname   == other.nickname
    end

  end
end
