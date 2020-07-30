require 'aspen'

# I'm not sure Statement makes sense to test like this. What does it do?

describe Aspen::Statement do

  let(:text) { "(Matt) [knows] (Brianna)." }
  let (:discourse) { 
    Aspen::Discourse.from_yaml("default:\n  label: Person")
  }

  let (:statement) { Aspen::Statement.from_text(text, discourse: discourse) }


  it "constructs valid statements with nodes" do
    expect(statement.origin).to be_an(Aspen::Node)
    expect(statement.origin.attributes.values.first).to eq("Matt")

    expect(statement.destination).to be_an(Aspen::Node)
    expect(statement.destination.attributes.values.first).to eq("Brianna")
  end

  it "constructs valid statements with edges" do
    expect(statement.edge).to be_an(Aspen::Edge)
    expect(statement.edge.to_cypher).to eq("-[:KNOWS]->")
  end


  let (:concert) {
    Aspen::Statement.from_text("(Marty McFly) [played] (Johnny B. Goode).", discourse: discourse)
  }

  it "lets non-ending periods pass through" do
    expect(concert.origin.attributes.values.first).to eq("Marty McFly")
    # expect(concert.edge.to_cypher).to eq("-[:PLAYED]->")
    expect(concert.destination.attributes.values.first).to eq("Johnny B. Goode")
  end

end
