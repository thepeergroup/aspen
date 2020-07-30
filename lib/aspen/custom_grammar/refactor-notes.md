..

CustomGrammar and Grammar are the same thing.
Matcher might be where the call to the compiler belongs.

Maybe combine Grammar into CustomGrammar
  Rename ^Grammar$ -> to CustomGrammar everywhere
  Move Matcher to CustomGrammar::Matcher

Okay, so, we've got the statement
  With the statement, we find a matching grammar element, the Matcher.
  With the Matcher, we get the results (just need to reimplement this).
  But the AST will contain information about the segments,
    like what type is associated with each var name.
    And if we fill out CustomGrammar::Nodes::Type like we did before,
    maybe we can have converters there!


What if the CustomGrammar compiler does something special:

It returns a CustomGrammar::Processor, which has:

  - the statement
  - the type registry (which var names go with which types), including the converters to convert them to those types.
  - the template

This is fed to CustomStatement, which ONLY figures out nodes and cypher.

```
Hash[
  pattern.match(str).named_captures.map do |capture|
    name, value = *capture
    type = @legend[name]
    case type
    when :SEGMENT_MATCH_NUMERIC
      case value
      when INTEGER then value.delete(',').to_i
      when FLOAT   then value.delete(',').to_f
      else
        raise ArgumentError, "Numeric value #{value} doesn't match INTEGER or FLOAT."
      end
    when :SEGMENT_MATCH_STRING
      value.to_s
    when :SEGMENT_MATCH_NODE
      value
    end
    [name, [type, value]]
  end
]
```