require 'dry/container'

module Aspen
  class Configuration

    include Dry::Container::Mixin

    attr_reader :text

    def initialize(config_text)
      @text = config_text
      process_lines(@text)
    end

    def default_node_label
      resolve("default.unlabeled")[:label]
    end

    def default_node_attr_name
      resolve("default.unlabeled")[:attr_name]
    end

    def default_attr_name_for_label(label)
      resolve("default.attr_names.#{label}")
    rescue Dry::Container::Error => e
      raise Aspen::ConfigurationError, <<~ERROR


        I don't know what attribute is supposed to be assigned by default
        to any node with the label `#{label}`.

        To fix this, use `default_attribute`. For example, if the default
        attribute should be the #{label}'s name, write this:

            default_attribute #{label}, name
      ERROR
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

    private

    def process_line(line)
      case line
      when /^\s*$/
        # NO OP - skip empty lines
      when /^default\s/
        default_registered = begin
          resolve("default.unlabeled")
        rescue Dry::Container::Error
          false
        end
        if default_registered
          raise Aspen::ConfigurationError, <<~ERROR
            You have already set a default label and attribute name for unlabeled nodes.
              # TODO List them

            Your configuration is trying to set a second set:
              # TODO List them

            Please edit your configuration so it only has one `default` line. You may, however,
            use multiple `default_attribute` lines to set defaults for a specific label.
          ERROR
        else
          _, _, info = line.partition(" ")
          label, attr_name = info.split(", ").map(&:strip)
          contract = Aspen::Contracts::DefaultAttributeContract.new
          result = contract.call(label: label, attr_name: attr_name)
          if result.errors.any?
            raise Aspen::ConfigurationError, result.errors.map {|k, v| "#{k} #{Array(v).join(", ")}"}
          end

          namespace('default') do
            register('unlabeled', { label: label, attr_name: attr_name })
            namespace('attr_names') do
              register(label, attr_name)
            end
          end
        end
      when /^default_attribute\s/
        _, _, info = line.partition(" ")
        label, attr_name = info.split(", ").map(&:strip)
        contract = Aspen::Contracts::DefaultAttributeContract.new
        result = contract.call(label: label, attr_name: attr_name)
        if result.errors.any?
          raise Aspen::ConfigurationError, result.errors.map {|k, v| "#{k} #{Array(v).join(", ")}"}
        end

        namespace('default') do
          namespace('attr_names') do
            register(label, attr_name)
          end
        end
      when /^reciprocal\s/
        _, _, rels = line.partition(" ")
        rel_names = rels.split(",").map(&:strip)

        namespace('relationships') do
          register('reciprocal', rel_names)
        end
      when /^(protect|allow|require|implicit)\s*/
        raise NotImplementedError, <<~ERROR
          These keywords are in the plans, but they're not yet ready!
              protect, allow, require, implicit
        ERROR
      else
        first_word = line.match(/^\w+/)
        raise Aspen::ConfigurationError, <<~ERROR
          Your configuration includes a line that starts with #{first_word}.
          This is not a valid configuration option.
        ERROR
      end
    end

    def process_lines(text)
      text.lines.each { |line| process_line(line) }
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
