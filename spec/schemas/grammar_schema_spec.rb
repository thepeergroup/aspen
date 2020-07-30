require 'aspen/schemas/grammar_schema'

describe Aspen::Schemas::GrammarSchema do

  # TODO: Check that there are no unreferenced variables in the templates.

  let (:errors) { described_class.call(grammar).errors }

  context "empty" do
    let(:grammar) { Hash.new }
    it "rejects blank grammars" do
      expect(errors).to_not be_empty
    end
  end

  context "with keys" do
    let(:grammar) {
      { match: ["hi", "text"], template: "hi" }
    }
    it "validates" do
      expect(errors).to be_empty
    end
  end

  context "with valid, matching variables" do
    let(:grammar) {
      {
        match: ["(Person a) met (Person b)."],
        template: "{{{a}}}-[:MET]->{{{b}}}"
      }
    }
    it "validates" do
      expect(errors).to be_empty
    end
  end

  context "with incorrect variables" do
    let(:grammar) {
      {
        match: ["(Person a) met (Person b)."],
        template: "{{{x}}}-[:MET]->{{{b}}}"
      }
    }
    pending "returns an error" do
      fail "Not yet implemented"
      expect(errors).to_not be_empty
    end
  end

  context "with unused variables" do
    let(:grammar) {
      {
        match: ["(Person a) met (Person b)."],
        template: "{{{a}}}-[:MET]->(:Person { name: \"Jack\" })"
      }
    }
    pending "warns the user, but permits it" do
      fail "check that logger received the warning"
      expect(errors).to be_empty
    end
  end
end
