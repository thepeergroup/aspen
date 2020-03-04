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

    let(:employer_umass) {
      Aspen::Node.new(label: "Employer", attributes: { name: "UMass Boston" })
    }

    context "when the attribute value is different" do
      let(:statements) {
        [
          instance_double("Statement", origin: person_matt, destination: person_brianna, is_an?: true),
          instance_double("Statement", origin: person_matt, destination: employer_umass, is_an?: true)
        ]
      }

      pending "nicknames nodes using just the attribute" do
        subject.load_statements(statements)
        expect(subject.needs_label_namespace?).to be false
        # expect the nodes to be simply nicknamed
      end
    end

    context "when the attribute values collide" do
      let(:colliding_nodes) { [person_matt, employer_matt] }

      pending "nicknames nodes using a label namespace" do
        subject.load_statements(raise)
        expect(subject.needs_label_namespace?).to be true
        # expect the nodes to be nicknamed with namespaces
      end
    end

    context "when the attribute values are exact overlaps" do
      let(:colliding_nodes) { [person_matt, person_brianna, person_matt] }

      pending "results in a unique set of nicknamed nodes" do
        subject.load_statements(raise)
        expect(subject.needs_label_namespace?).to be false
        # expect the nodes to be simply nicknamed
      end
    end
  end

  context "with multiple attributes" do

    let(:person_matt) {
      Aspen::Node.new(label: "Person", attributes: { first_name: "Matt" })
    }

    let(:person_matt_cloyd) {
      Aspen::Node.new(label: "Person", attributes: { first_name: "Matt", last_name: "Cloyd" })
    }

    pending "raises an error with namespace collision" do
      fail
      # We can do this work now without having "Full Form" which converts
      # text into multi-attribute nodes. We can just construct those nodes here.
    end

  end

end
