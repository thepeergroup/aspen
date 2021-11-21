require 'aspen'

describe Aspen::Statement do

  context "with a valid statement" do
    let(:subject) {
      Aspen::Statement.new(
        edge:        Aspen::Edge.new(word: "hired"),
        origin:      Aspen::Node.new(label: "Company", attributes: { name: "Kabletown" }),
        destination: Aspen::Node.new(label: "Person", attributes: { name: "Jack" }),
      )
    }

    it "has a type" do
      expect(subject.type).to eq(:vanilla)
    end

    it "has a signature" do
      expect(subject.signature).to eq("(Company)-[HIRED]->(Person)")
    end
  end

  context "with a reciprocal relationship" do
    let(:subject) {
      Aspen::Statement.new(
        edge:        Aspen::Edge.new(word: "knows", reciprocal: true),
        origin:      Aspen::Node.new(label: "Person", attributes: { name: "Liz" }),
        destination: Aspen::Node.new(label: "Person", attributes: { name: "Jack" }),
      )
    }

    it "has a type" do
      expect(subject.type).to eq(:vanilla)
    end

    it "has a signature" do
      expect(subject.signature).to eq("(Person)-[KNOWS]-(Person)")
    end
  end

end
