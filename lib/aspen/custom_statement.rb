require 'dry/types'

# A result set looks like this:
# {
#   "a"=>[[:SEGMENT_MATCH_NODE, "Person"], "Jeanne"],
#   "role"=>[[:SEGMENT_MATCH_STRING], "\"case manager\""],
#   "count"=>[[:SEGMENT_MATCH_NUMERIC], 1]
# }

module Aspen
  class CustomStatement < AbstractStatement

    include Dry::Monads[:maybe]

    def initialize(content, env={})
      @content  = content
      @env      = env
      # SMELL: We're duplicating a grammar lookup here.
      @matcher  = @env.grammar.matcher_for(content).value!
      @results  = @env.grammar.results_for(content)
      @template = @matcher.template
    end

    # def nodes
      # TODO
    # end

    # def to_cypher
    #   Mustache.render(template, nicknamed_results)
    # end
  end
end
