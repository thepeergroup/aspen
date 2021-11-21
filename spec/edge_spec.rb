require 'aspen'

describe Aspen::Edge do

=begin

  Redo this whole file. Just check that Node returns
  the right nicknames and formats, given certain inputs.

=end

  context "with a valid edge" do
    let(:subject) {
      Aspen::Edge.new(word: "threw a dodgeball at")
    }

    it 'renders cypher' do
      expect(subject.to_cypher).to eq("-[:THREW_A_DODGEBALL_AT]->")
    end

    it "has a signature" do
      expect(subject.signature).to eq("-[THREW_A_DODGEBALL_AT]->")
    end

    context "with a reciprocal relationship" do
      let(:subject) {
        Aspen::Edge.new(word: "knows", reciprocal: true)
      }

      it "renders cypher" do
        expect(subject.to_cypher).to eq("-[:KNOWS]-")
      end

      it "has a signature" do
        expect(subject.signature).to eq("-[KNOWS]-")
      end
    end

  end

end
