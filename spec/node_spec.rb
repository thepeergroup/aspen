require 'aspen'

describe Aspen::Node do

  # TODO Stub lookups
  let(:context) { Aspen::Configuration.new("default Person, name\ndefault_attribute Employer, co_name") }

  context 'short form' do
    let(:expected) {
      Aspen::Node.new(
        label:      'Person',
        attributes: { 'name' => 'Matt' },
        nickname:   'person_matt'
      )
    }

    context 'from text' do
      let (:text) { '(Matt)' }
      let (:actual) { Aspen::Node.from_text(text, context) }

      it 'renders a node' do
        expect(actual).to eq(expected)
      end
    end

    context 'from result' do
      let (:result) { [[:SEGMENT_MATCH_NODE, "Person"], "Matt"] }
      let (:actual) { Aspen::Node.from_result(result, context) }

      it 'renders a node' do
        expect(actual).to eq(expected)
      end
    end
  end


  context 'default-attribute form' do
    let(:text) { '(Employer, UMass Boston)' }
    let(:expected) {
      Aspen::Node.new(
        label:      'Employer',
        attributes: { 'co_name' => 'UMass Boston' },
        nickname:   'employer_umass_boston'
      )
    }

    it 'renders a node' do
      actual = Aspen::Node.from_text(text, context)
      expect(actual).to eq(expected)
    end
  end


  context 'full form' do
    let(:expected) {
      Aspen::Node.new(
        label:      'Person',
        attributes: { 'name' => 'Matt', 'age' => 31 },
        nickname:   'person_matt'
      )
    }

    context "from text" do
      let(:text) { '(Person { name: "Matt", age: 31 })' }
      let (:actual) { Aspen::Node.from_text(text, context) }

      it 'renders a node' do
        expect(actual).to eq(expected)
      end
    end

    context "from result" do
      let(:result) { [[:SEGMENT_MATCH_NODE, "Person"], "(Person { name: \"Hélène\", age: 31 })"] }
      let (:actual) { Aspen::Node.from_result(result, context) }

      it 'renders a node' do
        expect(actual).to eq(
          Aspen::Node.new(
          label:      'Person',
          attributes: { 'name' => 'Hélène', 'age' => 31 },
          nickname:   'person_helene'
        ))
      end
    end

  end


end
