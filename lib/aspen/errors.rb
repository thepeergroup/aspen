module Aspen
  class Error < StandardError ; end
  class LookupError < Error ; end
  class ConfigurationError < Error ; end
  class MatchError < Error ; end
  class AttributeCollisionError < Error ; end

  class Errors
    def self.messages(lookup, *args)
      _messages[lookup].call(args)
    end

    private

    def self._messages
      {
        default_already_registered: -> (args) {
          <<~ERROR
            You have already set a default label and attribute name for unlabeled nodes.
              # TODO List them

            Your configuration is trying to set a second set:
              # TODO List them

            Please edit your configuration so it only has one `default` line. You may, however,
            use multiple `default_attribute` lines to set defaults for a specific label.
          ERROR
        },

        bad_keyword: -> (args) {
          <<~ERROR
            Your configuration includes a line that starts with "#{args.first}".
            This is not a valid configuration option.
          ERROR
        },

        expected_match_precedent: -> (args) {
          <<~ERROR
            Indented two lines, so expected the last line to be either
            :MATCH_START or :MATCH_TO, but was: #{args.first}.
          ERROR
        },

        need_default_attribute: -> (args) {
          <<~ERROR
            I don't know what attribute is supposed to be assigned by default
            to any node with the label `#{args.first}`.

            To fix this, use `default_attribute`. For example, if the default
            attribute should be the #{args.first}'s name, write this:

                default_attribute #{args.first}, name

          ERROR
        },

        no_default_line: -> (args) {
          <<~ERROR
            Nothing has been registered as the default node label. Please add
            a line that indicates which label and attribute name should be applied
            to unlabeled nodes.

            Example:

              default Person, name

          ERROR
        },

        no_tag: -> (args) {
          <<~ERROR
            There's no configuration option that matches the line:

              #{args.first.inspect}

            Maybe it's a spelling error?

          ERROR
        }
      }
    end
  end
end
