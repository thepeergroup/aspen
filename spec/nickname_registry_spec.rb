require 'aspen'

describe Aspen::NicknameRegistry do

  let(:subject) { Aspen::NicknameRegistry.new() }

  context "with a single attribute" do

    let(:person_matt) {
      Aspen::Node.new(label: "Person", attributes: { name: "Matt Cloyd" })
    }

    let(:person_brianna) {
      Aspen::Node.new(label: "Person", attributes: { name: "Brianna" })
    }

    let(:employer_matt) {
      Aspen::Node.new(label: "Employer", attributes: { name: "Matt Cloyd" })
    }

    let(:employer_umass_boston) {
      Aspen::Node.new(label: "Employer", attributes: { name: "UMass Boston" })
    }

    context "when the attribute value is different" do
      let(:unique_nodes) { [person_matt, person_brianna, employer_umass_boston] }

      it "nicknames nodes using just the attribute" do
        subject.load_nodes(unique_nodes)
        expect(subject.needs_label_namespace?).to be false
        expect(subject.nicknamed_nodes.map(&:nickname)).to eql(['matt-cloyd', 'brianna', 'umass-boston'])
      end
    end

    context "when the attribute values collide" do
      let(:colliding_nodes) { [person_matt, employer_matt] }

      it "nicknames nodes using a label namespace" do
        subject.load_nodes(colliding_nodes)
        expect(subject.needs_label_namespace?).to be true
        expect(subject.nicknamed_nodes.map(&:nickname)).to eql(['person-matt-cloyd', 'employer-matt-cloyd'])
      end
    end

    context "when the attribute values are exact overlaps" do
      let(:colliding_nodes) { [person_matt, person_brianna, person_matt] }

      it "results in a unique set of nicknamed nodes" do
        subject.load_nodes(colliding_nodes)
        expect(subject.needs_label_namespace?).to be false
        expect(subject.nicknamed_nodes.map(&:nickname)).to eql(['matt-cloyd', 'brianna'])
      end
    end

  end
end
