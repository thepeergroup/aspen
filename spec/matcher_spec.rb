require 'aspen'

describe Aspen::Matcher do

=begin

map
  (Person a) donated $(float amt) to (Person b).
  (Person a) gave (Person b) $(float amt).
to
  ({a})-[:GAVE_DONATION]->(:Donation { amount: {amt} })<-[:RECEIVED_DONATION]-({b})

let(:numeric_pattern) { "(?<a>NODE_REGEX) donated \$(?<amt>FLOAT_REGEX) to (?<b>NODE_REGEX)." }
let(:numeric_results) { { a: Node, amt: number, b: Node } }

let(:string_statement) { "(string a) donated $(string amt) to (string b)." }
let(:string_pattern) { TODO }
let(:string_results) { TODO }

let(:node_statement) { "(Person a) knows (Person b)." }

let(:multi_statement) { "(Person a) donated $(float amt) to (Person b)." }
let(:multi_pattern) { "(?<a>NODE_REGEX) donated \$(?<amt>FLOAT_REGEX) to (?<b>NODE_REGEX)." }
let(:multi_results) { { a: Node, amt: number, b: Node } }

Query language:

most common feelings connected by 1 degree to (matcher)
         -> Feeling
=end

  context "stepwise" do

    let(:statement) { "I have (numeric apple_count) apples." }
    let(:template) { "(:Person { name: \"me\", apple_count: {{apple_count}} })" }
    let(:aspen) { "I have 1,000 apples." }

    it "renders a type-based pattern" do
      matcher = Aspen::Matcher.new(statement, template)
      pattern = /I have (?-mix:(?<apple_count>[\d,]+\.?\d*)) apples./
      expect(matcher.pattern).to eq(pattern)
      expect(matcher.match?(aspen)).to be true

      expect(matcher.matches!(aspen)).to eq({ "apple_count" => 1_000 })
      expect(matcher.render_cypher(aspen)).to eq("(:Person { name: \"me\", apple_count: 1000 })")
    end

  end

  context "numeric values" do

    let(:numeric_statement) { "I have (numeric apple_count) apples." }
    let(:numeric_cypher_template)  { "(:Person { name: \"Matt\", apples: {{apple_count}} })" }
    let(:numeric_cypher_statement) { "(:Person { name: \"Matt\", apples: 10 })" }

    context "without commas" do
      let(:numeric_aspen_statement)  { "I have 10 apples." }
      let(:subject) {
        grammar = Aspen::Matcher.new(numeric_statement, numeric_cypher_template)
        grammar.render_cypher(numeric_aspen_statement)
      }

      it "renders custom Cypher" do
        expect(subject).to eq(numeric_cypher_statement)
      end
    end

    context "with commas" do
      let(:numeric_aspen_statement)  { "I have 1,000 apples." }
      let(:subject) {
        grammar = Aspen::Matcher.new(numeric_statement, numeric_cypher_template)
        grammar.render_cypher(numeric_aspen_statement)
      }

      it "handles commas gracefully" do
        expect(subject).to eq("(:Person { name: \"Matt\", apples: 1000 })")
      end
    end
  end # numeric

  context "string values" do

    let(:string_map) { "I have a dog named (string dog_name)." }
    let(:string_cypher_template)  { "(:Person { name: \"Matt\" })-[:OWNS]->(:Pet { type: \"dog\", name: {{{dog_name}}} })" }
    let(:string_aspen_statement)  { "I have a dog named \"Fido\"." }
    let(:string_cypher_statement) { "(:Person { name: \"Matt\" })-[:OWNS]->(:Pet { type: \"dog\", name: \"Fido\" })" }

    let(:subject) {
      grammar = Aspen::Matcher.new(string_map, string_cypher_template)
      grammar.render_cypher(string_aspen_statement)
    }

    it "renders custom Cypher" do
      expect(subject).to eq(string_cypher_statement)
    end
  end # string

  context "mixed values" do

    let(:mixed_map) { "(Person a) gave (Person b) $(numeric amt)." }
    let(:mixed_cypher_template) { "{{a}}-[:GAVE_DONATION]->(:Donation { amount: {{amt}} })<-[:RECEIVED_DONATION]-{{b}}" }
    let(:mixed_aspen_statement) { "Matt gave Hélène $2,000." }
    let(:mixed_cypher_statement) {
      <<~CYPHER
        MERGE (person_matt:Person { name: "Matt" })
        MERGE (person_helene:Person { name: "Hélène" })
        MERGE (person_matt)-[:GAVE_DONATION]->(:Donation { amount: 2000 })<-[:RECEIVED_DONATION]-(person_helene)
      CYPHER
    }

    let(:subject) {
      grammar = Aspen::Matcher.new(mixed_map, mixed_cypher_template)
      grammar.render_cypher(mixed_aspen_statement)
    }

    it "renders custom Cypher" do
      expect(subject).to eq(mixed_cypher_statement)
    end
  end # mixed
end
