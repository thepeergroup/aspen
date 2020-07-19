require 'aspen'

describe Aspen::CustomStatement do

  let(:first_match_statement) { "(Person a) gave (Person b) $(numeric amt)." }
  let(:matchers) {
    [
      Aspen::Matcher.new(
        first_match_statement,
        "{{{a}}}-[:GAVE_DONATION]->(:Donation { amount: {{amt}} })<-[:RECEIVED_DONATION]-{{{b}}}"
      ),
      Aspen::Matcher.new(
        "(Person a) donated $(numeric amt) to (Person b).",
        "{{{a}}}-[:GAVE_DONATION]->(:Donation { amount: {{amt}} })<-[:RECEIVED_DONATION]-{{{b}}}"
      )
    ]
  }

  let(:grammar) {
    grammar = Aspen::Grammar.new()
    grammar.add(matchers)
    grammar
  }

  let(:discourse) {
    _discourse = Aspen::Discourse.from_yaml("default:\n  label: Person")
    _discourse.add_grammar(grammar)
    _discourse
  }

  let(:line) { "Matt gave Hélène $2,000." }

  let(:custom_statement) { Aspen::CustomStatement.from_text(line, context: discourse) }


  context "valid line" do

    context "with nodes in simple form" do

      it "returns all nodes" do
        names = custom_statement.nodes.map { |n| n.attributes["name"] }
        expect(names).to eq %w( Matt Hélène )
      end

      it "returns a Cypher statement with nicknames" do
        expected_cypher = <<~CYPHER
          (person_matt)-[:GAVE_DONATION]->(:Donation { amount: 2000 })<-[:RECEIVED_DONATION]-(person_helene)
        CYPHER
        expect(custom_statement.to_cypher).to eq(expected_cypher.strip)
      end
    end

    context "with nodes in simple and full form" do
      let(:line) {
        "Matt gave (Person { name: \"Hélène\", age: 31 }) $2,000."
      }

      it "returns all nodes" do
        names = custom_statement.nodes.map { |n| n.attributes["name"] }
        expect(custom_statement.nodes.last.attributes["age"]).to eq(31)
        expect(names).to eq %w( Matt Hélène )
      end

      it "returns a Cypher statement with nicknames" do
        expected_cypher = <<~CYPHER
          (person_matt)-[:GAVE_DONATION]->(:Donation { amount: 2000 })<-[:RECEIVED_DONATION]-(person_helene)
        CYPHER
        expect(custom_statement.to_cypher).to eq(expected_cypher.strip)
      end
    end
  end

end


# let(:numeric_cypher_statement) { "(:Person { name: \"Matt\", apples: 10 })" }
# let(:string_cypher_statement) { "(:Person { name: \"Matt\" })-[:OWNS]->(:Pet { type: \"dog\", name: \"Fido\" })" }
# let(:mixed_cypher_statement) {
#   <<~CYPHER
#         MERGE (person_matt:Person { name: "Matt" })
#         MERGE (person_helene:Person { name: "Hélène" })
#         MERGE (person_matt)-[:GAVE_DONATION]->(:Donation { amount: 2000 })<-[:RECEIVED_DONATION]-(person_helene)
#       CYPHER
#     }
