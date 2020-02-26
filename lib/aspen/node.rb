module Aspen
  class Node

    attr_reader :label, :attributes, :nickname

    def initialize(label: , attributes: {}, nickname: )
      @label = label
      @attributes = attributes
      @nickname = nickname
    end

    def to_s
      "(#{nickname}:#{label} #{ attribute_string })"
    end

    def attribute_string
      attributes.to_s.gsub(/"(?<token>\w+)"=>/, '\k<token>: ')
    end

    def self.from_text(node_text, context)
      new(
        label: context.default_node_label,
        attributes: { context.default_node_attr_name => node_text },
        nickname: node_text.downcase
      )
    end
  end
end
