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

    def self.from_hash(data = {})
      raise ArgumentError, "Must be a hash, was a #{data.class}" unless data.is_a?(Hash)
      result = Schemas::DiscourseSchema.call(data)
      if result.success?
        new(data)
      else
        # TODO: Improve this output for human readability
        raise Aspen::Error, result.errors.messages.to_s
      end
    end

    def self.assert(data)
      return nil if data.nil?
      case data.class.to_s
      when "Aspen::Discourse" then data
      when "Hash"   then from_hash(data)
      when "String" then from_yaml(data)
      else
        raise ArgumentError, "Must be a Hash, string (containing YAML), or Aspen::Discourse, got:\n\t#{data} (#{data.class})"
      end
    end

    def initialize(data = {})
      @data = data.with_indifferent_access
      @grammar = Aspen::CustomGrammar::Grammar.new
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

    def allowed_labels
      @al ||= whitelist_for(:nodes)
    end

    def allowed_edges
      @ae ||= whitelist_for(:edges)
    end

    def allows_label?(label)
      allowed_labels.empty? || allowed_labels.include?(label)
    end

    def allows_edge?(edge)
      allowed_edges.empty? || allowed_edges.include?(edge)
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
      maybe_whitelist = Maybe(@data.dig(:allow_only, stuff))
      list = maybe_whitelist.value_or([])
      return list if list.is_a? Array  # If it's already a YAML list, great.
      list.split(",").map(&:strip)      # Otherwise, split the comma-separated string
    end

    # Converts multiple lines
    def process_grammar
      return false unless configured_grammar
      configured_grammar.each do |block|
        Array(block.fetch(:match)).each do |expression|
          matcher = Aspen::CustomGrammar::Matcher.new(
            expression: expression,
            template:   block.fetch(:template),
            pattern:    Aspen::CustomGrammar.compile_pattern(expression)
          )
          grammar.add(matcher)
        end
      end
    end

    def configured_grammar
      @cg ||= Maybe(@data.dig(:grammar)).value_or(false)
    end

  end
end
