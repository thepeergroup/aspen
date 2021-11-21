require 'aspen'

describe Aspen::Node do

=begin

  Redo this whole file. Just check that Node returns
  the right nicknames and formats, given certain inputs.

=end

  context "with a valid node" do
    let(:subject) {
      Aspen::Node.new(label: "Person", attributes: { name: "Liz" })
    }

    it "has a signature" do
      expect(subject.signature).to eq("(Person)")
    end
  end

end
