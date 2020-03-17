require 'dry/container'

module Aspen
  class Configuration

    include Dry::Container::Mixin

    attr_reader :text, :grammar, :tags

    def initialize(config_text)
      @text = config_text
      @cursor = 0
      @grammar = Aspen::Grammar.new()
      tag_lines
      process_tags
    end

    def add_grammar(grammar)
      @grammar = grammar
    end

    def default_node_label
      resolve("default.unlabeled")[:label]
    rescue Dry::Container::Error
      raise Aspen::ConfigurationError, Aspen::Errors.messages(:no_default_line)
    end

    def default_node_attr_name
      resolve("default.unlabeled")[:attr_name]
    end

    def default_attr_name_for_label(label)
      resolve("default.attr_names.#{label}")
    rescue Dry::Container::Error => e
      raise Aspen::ConfigurationError, Aspen::Errors.messages(:need_default_attribute, label)
    end

    def reciprocal
      resolve('relationships.reciprocal')
    rescue Dry::Container::Error => e
      raise Aspen::ConfigurationError, e.message
    end

    def reciprocal?(relationship)
      reciprocal.include? relationship
    end

    alias_method :reciprocal_relationships, :reciprocal

    def tag_lines
      @tags = []
      @text.lines.each { |line| tag_line(line) }
      @tags
    end

    def tag_line(line)
      @tags << case line
      when /^\s*$/
        [:EMPTY_LINE]
      when /^default\s/
        [:DEFAULT, split_attrs(line)]
      when /^default_attribute\s/
        [:DEFAULT_ATTRIBUTE, split_attrs(line)]
      when /^reciprocal\s/
        [:RECIPROCAL, split_attrs(line)]
      when /^match/
        [:MATCH_START]
      when /^to/
        [:MATCH_TO]
      # Two spaces, followed by non-space characters
      when /^\s{2}\S/
        case @tags.last.first
        # A match statement can come after a start or another statement
        when :MATCH_START, :MATCH_STATEMENT
          [:MATCH_STATEMENT, line.strip]
        # A match template can have multiple lines.
        when :MATCH_TO, :MATCH_TEMPLATE then
          [:MATCH_TEMPLATE, line.strip]
        else
          raise Aspen::ConfigurationError, Aspen::Errors.messages(:expected_match_precedent, @tags.last.first)
        end
      else
        raise Aspen::ConfigurationError, Aspen::Errors.messages(:no_tag, line)
      end
    end

    private

    def split_attrs(line)
      _, _, info = line.partition(" ")
      info.split(",").map(&:strip)
    end

    def process_tag(tagged_line)
      # puts "tagged line - #{tagged_line.inspect}"
      tag, args = tagged_line
      case tag
      when :EMPTY_LINE
        # NO OP - skip empty lines
      when :DEFAULT
        if default_registered
          raise Aspen::ConfigurationError, Aspen::Errors.messages(:default_already_registered)
        else
          label, attr_name = assert_default_contract(args)
          register("default.unlabeled", { label: label, attr_name: attr_name })
          register("default.attr_names.#{label}", attr_name)
        end
      when :DEFAULT_ATTRIBUTE
        label, attr_name = assert_default_contract(args)
        register("default.attr_names.#{label}", attr_name)
      when :RECIPROCAL
        register("relationships.reciprocal", args)
      when :MATCH_START
        @under_construction = []
      when :MATCH_TO
        # NO OP
      when :MATCH_STATEMENT
        @under_construction << [:STATEMENT, args]
      when :MATCH_TEMPLATE
        @under_construction << [:TEMPLATE, args]
        statements = @under_construction.select { |e| e.first == :STATEMENT }.map(&:last)
        template = @under_construction.select { |e| e.first == :TEMPLATE }.map(&:last).join("\n")
        statements.map do |statement|
          @grammar.add Matcher.new(statement, template)
        end
        @under_construction = [] # Reset
      else
        raise Aspen::ConfigurationError, Aspen::Errors.messages(:bad_keyword)
      end
    end

    def process_tags
      @under_construction = []
      @tags.each { |tag| process_tag(tag) }
    end

    def assert_default_contract(args)
      label, attr_name = args
      contract = Aspen::Contracts::DefaultAttributeContract.new
      result = contract.call(label: label, attr_name: attr_name)
      if result.errors.any?
        raise Aspen::ConfigurationError, result.errors.map { |k, v| "#{k} #{Array(v).join(", ")}" }
      end
      [label, attr_name]
    end

    def default_registered
      begin
        resolve("default.unlabeled")
      rescue Dry::Container::Error
        false
      end
    end

    def has_default_line?
      default_line.present?
    end

    def default_info
      _, _, info = default_line.partition(" ")
      info.split(", ").map(&:strip)
    end

  end
end
