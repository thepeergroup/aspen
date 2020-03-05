require 'active_support/core_ext/string/inflections'
require 'dry/monads'

module Aspen
  class Node

    extend Dry::Monads[:maybe]
    include Dry::Monads[:maybe]

    # Default (D) Form: (Johnny B. Goode)
    DEFAULT_FORM = /\(([\w\s\.]+?)\)/

    # Default-Attribute (DA) Form: (Employer, UMass Boston)
    DEFAULT_ATTR_FORM = /\((\w+,\s[\w\s\.]+)\)/

    # TODO:
    # Full Cypher (F) Form: (Employer name: "UMass Boston", location: "William Morrissey Blvd.")

    attr_reader :label, :attributes, :nickname
    attr_writer :nickname

    def initialize(label: , attributes: {}, nickname: nil)
      @label = label
      @attributes = attributes
      if Maybe(nickname).value_or(false)
        @nickname = nickname
      end
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
        gsub(/"(?<token>\w+)"=>/, '\k<token>: ').
        # This puts a single space inside curly braces.
        gsub(/\{(\s*)/, "{ ").
        gsub(/(\s*)\}/, " }")
    end

    def self.from_text(node_text, context)
      node_info = case node_text
      when DEFAULT_FORM
        { label:      None(),
          attr_name:  None(),
          attr_value: Maybe(node_text.match(DEFAULT_FORM).captures.first)
        }
      when DEFAULT_ATTR_FORM
        label, _, attr_value = node_text.match(DEFAULT_ATTR_FORM).captures.first.partition(", ")
        # TODO: Validate form
        { label:      Maybe(label),
          attr_name:  None(),
          attr_value: Maybe(attr_value)
        }
      else
        raise Aspen::Error, <<~ERROR
          The node is not formatted correctly. It should either be like
          - (Matt), with a `default` statement in the config, or
          - (Employer, UMass Boston), with a `default_attribute` statement in the config

          Instead, it was
            #{node_text}
        ERROR
      end

      label     = node_info[:label].value_or(context.default_node_label)
      attr_name = node_info[:attr_name].value_or(
        context.default_attr_name_for_label(label)
      )
      attr_value = node_info[:attr_value].value!

      new(
        label: label,
        attributes: { attr_name => attr_value },
        nickname: "#{label}-#{attr_value}".parameterize.underscore
      )
    end
  end
end
