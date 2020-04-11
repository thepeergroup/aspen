require 'aspen/schemas/grammar_schema'

describe Aspen::Schemas::GrammarSchema do

  let(:subject) {
    described_class.call(grammar)
  }

  context "empty" do
    let(:grammar) do
      {}
    end
    it "has errors" do
      expect(subject.errors).to_not be_empty
    end
  end

  context "with keys" do
    let(:grammar) do
      { match: ["hi", "text"], template: "hi" }
    end
    it "is ok for now" do
      expect(subject.errors).to be_empty
    end
  end
end
