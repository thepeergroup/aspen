require 'aspen'

describe Aspen::Statement do

  let(:text) { "(Matt) [knows] (Brianna)." }

  let (:statement) { Aspen::Statement.from_text(text) }

  it "construct valid statements with tagged words" do
    expect(statement.origin).to be_a(Aspen::Statement::TaggedWord)
    expect(statement.origin.tag).to eq(:node)
    expect(statement.origin.word).to eq("(Matt)")

    expect(statement.edge).to be_a(Aspen::Statement::TaggedWord)
    expect(statement.edge.tag).to eq(:edge)
    expect(statement.edge.word).to eq("[knows]")

    expect(statement.destination).to be_a(Aspen::Statement::TaggedWord)
    expect(statement.destination.tag).to eq(:node)
    expect(statement.destination.word).to eq("(Brianna)")
  end

  it "lets non-ending periods pass through" do
    concert = Aspen::Statement.from_text("(Marty McFly) [played] (Johnny B. Goode).")
    expect(concert.origin.word).to eq("(Marty McFly)")
    expect(concert.edge.word).to eq("[played]")
    expect(concert.destination.word).to eq("(Johnny B. Goode)")
  end

end
