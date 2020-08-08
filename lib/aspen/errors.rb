module Aspen

  class Error          < StandardError ; end

  class LexError       < Error ; end
  class ParseError     < Error ; end
  class CompileError   < Error ; end
  class MatchError     < Error ; end

  class AttributeCollisionError < Error ; end

  class Errors
    def self.messages(lookup, *args)
      _messages[lookup].call(args)
    end

    private

    def self._messages
      {
        unexpected_token: -> (args) {
          <<~ERROR
            Within state :#{args.last}, unexpected token "#{args.first.peek(1)}" at position #{args.first.pos}.
            Next 30 characters: #{args.first.peek(30).inspect}
          ERROR
        },
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

        no_body_tag: -> (args) {
          <<~ERROR
            We couldn't find a match for the following line

              #{args.first}

            among the following patterns

              #{args.last.registry.map(&:pattern).map(&:inspect).join("\n")}

            Every line should either match a custom grammar definition, or
            start with a node, like:

              (Matt) [knows] (Brianna).

          ERROR
        },

        no_config_tag: -> (args) {
          <<~ERROR
            There's no configuration option that matches the line:

              #{args.first}

            Maybe it's a spelling error?

          ERROR
        },

        no_grammar_match: -> (args) {
          <<~ERROR
            Expected pattern:

              #{pattern}

            to match

              #{str}
          ERROR
        },

        no_statement_tag: -> (args) {
          <<~ERROR
            Couldn't figure out how to tag '#{args.first}'."
          ERROR
        },

        statement_node_count: -> (args) {
          <<~ERROR
            A statement must have exactly two nodes, but we found #{args.first.count} in this statement:

              #{args.last}

            The nodes are:

              #{args.first.map(&:last).join(", ").inspect}

          ERROR
        },

        statement_edge_count: -> (args) {
          <<~ERROR
            A statement must have exactly one edge, but we found #{args.first.count} in this statement:

              #{args.last}

            The edges are:

              #{args.first.map(&:last).join(", ").inspect}

          ERROR
        },

      }
    end
  end
end
