require 'aspen'

describe Aspen::Node do

  # TODO Stub lookups
  let(:context) { Aspen::Configuration.new("default Person, name\ndefault_attribute Employer, co_name") }

  context 'short form' do
    let(:text) { '(Matt)' }
    let(:expected) {
      Aspen::Node.new(
        label:      'Person',
        attributes: { 'name' => 'Matt' },
        nickname:   'person_matt'
      )
    }

    it 'renders a node' do
      actual = Aspen::Node.from_text(text, context)
      expect(actual).to eq(expected)
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
    let(:text) { '(Person { name: "Matt", age: 31 })' }
    let(:expected) {
      Aspen::Node.new(
        label:      'Person',
        attributes: { 'name' => 'Matt', 'age' => 31 },
        nickname:   'person_matt'
      )
    }

    it 'renders a node' do
      actual = Aspen::Node.from_text(text, context)
      expect(actual).to eq(expected)
    end
  end
end
