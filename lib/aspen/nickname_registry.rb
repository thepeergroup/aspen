require 'dry/monads'

module Aspen
  class NicknameRegistry

    include Dry::Monads[:maybe]

    attr_reader :nodes

    def initialize()
      # NO OP
    end

    def load_nodes(node_list)
      unless Array(node_list).all? { |node| node.is_a? Node }
        raise ArgumentError, "Input to #load_nodes must be an array of Node objects"
      end
      @nodes = Array(node_list)
    end

    def needs_label_namespace?
      # We need to know:
      # If multiple nodes have the same attribute, do they have different labels?
      #
      # For every unique attribute value,
      attr_values = @nodes.map { |n| n.attributes.values.first }
      histogram_attr_values = histogram(attr_values)
      # If they have more than 1,
      values_to_check = histogram_attr_values.select { |val, count| val if count > 1 }
      # Are there more than one unique labels?
      # If so, we need to namespace it.
      needs_namespace = values_to_check.keys.detect do |value|
        uniq_labels_for_value = @nodes.map { |n| n.label }.uniq
        return uniq_labels_for_value.count > 1 ? true : false
      end

      Maybe(needs_namespace).value_or(false)
    end

    def histogram(values)
      values.inject(Hash.new(0)) do |hash, e|
        hash[e] += 1
        hash
      end
    end

    def nicknamed_nodes(unique: true)
      nicknamed_nodes = @nodes.map do |node|
        attribute_value = if needs_label_namespace?
          [node.label, node.attributes.values.first].join('-')
        else
          node.attributes.values.first
        end
        node.nickname = attribute_value.parameterize
        node
      end

      if unique
        nicknamed_nodes.uniq { |node| node.nickname }
      else
        nicknamed_nodes
      end
    end

  end
end
