require 'active_support/core_ext/hash/indifferent_access'
require 'dry/monads'
require 'yaml'

require 'aspen/schemas/discourse_schema'

module Aspen
  class Discourse

    include Dry::Monads[:maybe]

    attr_reader :data, :grammar

    def self.from_yaml(yaml)
      from_hash YAML.load(yaml)
    end

    def self.from_hash(data)
      result = Schemas::DiscourseSchema.call(data)
      if result.success?
        new(data)
      else
        raise Aspen::Error, result.errors
      end
    end

    def initialize(data = {})
      @data = data.with_indifferent_access
      @grammar = Grammar.new
      process_grammar
    end

    def default_label
      maybe_label = Maybe(@data.dig(:default, :label))
      maybe_label.value_or(Aspen::SystemDefault.label)
    end

    def default_attr_name(label)
      maybe_attr = Maybe(@data.dig(:default, :attributes, label.to_sym))
      maybe_attr.value_or(primary_default_attr_name)
    end

    def label_allowed?(label)
      list = whitelist_for(:nodes)
      return true if list.empty?
      list.include? label
    end

    def edge_allowed?(edge)
      list = whitelist_for(:relationships)
      return true if list.empty?
      list.include? edge
    end

    def reciprocal
      maybe_list = Maybe(@data.dig(:reciprocal))
      maybe_list.value_or(Array.new)
    end

    def reciprocal?(edge_name)
      reciprocal.include? edge_name
    end

    def add_grammar(grammar)
      @grammar = grammar
    end

    private

    def primary_default_attr_name
      maybe_attr = Maybe(@data.dig(:default, :attribute))
      maybe_attr.value_or(Aspen::SystemDefault.attr_name)
    end

    def whitelist_for(stuff)
      maybe_whitelist = Maybe(@data.dig(:only, stuff))
      maybe_whitelist.value_or("").split(",").map(&:strip)
    end

    def process_grammar
      return false unless configured_grammar
      configured_grammar.each do |block|
        Array(block.fetch(:match)).each do |matcher|
          matcher_object = Matcher.new(matcher, block.fetch(:template))
          grammar.add(matcher_object)
        end
      end
    end

    def configured_grammar
      @cg ||= Maybe(@data.dig(:grammar)).value_or(false)
    end

  end
end
