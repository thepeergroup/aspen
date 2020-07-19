require 'aspen'

describe Aspen do

  it "raises an error with an empty string" do
    expect { Aspen.compile_text(" ") }.to raise_error(Aspen::Error)
  end

  let(:aspen_paths) { Dir["spec/support/files/aspen/*.aspen"].sort }
  let(:cypher_paths) { Dir["spec/support/files/cypher/*.cql"].sort }
  let(:test_paths) { aspen_paths.zip(cypher_paths) }
  let(:test_files) {
    test_paths.map do |paths|
      paths.map { |path| File.read(path) }
    end
  }

  it "renders Aspen files" do
    @ct = 0
    test_files.each do |aspen, cypher|
      @ct += 1
      next if @ct == 4
      puts "Starting file ##{@ct}"
      expect(Aspen.compile_text(aspen, debug: true)).to eql(cypher)
    end
  end

  it "renders Aspen with non-annotated text" do
    aspen = "On this day, (Matt) was [interviewed by] (Mia), and it went well."
    cypher = <<~CYPHER
      MERGE (person_matt:Entity { name: "Matt" })
      MERGE (person_mia:Entity { name: "Mia" })

      MERGE (person_matt)-[:INTERVIEWED_BY]->(person_mia)
    CYPHER

    expect(Aspen.compile_text(aspen)).to eql(cypher)
  end

  # TODO: In file 8, catch that Jack and Jack Donaghy are collisions
  # TODO: Uncouple this from needing #default?, though it should need default_attribute

  let (:attribute_collision) {
    <<~ASPEN
    default Person, name
    reciprocal knows
    ----

    (Person { name: "Matt", age: 31 }) [knows] (Matt)
    ASPEN
  }

  pending "raises when attributes collide" do
    expect {
      Aspen.compile_text(attribute_collision)
    }.to raise_error(Aspen::AttributeCollisionError)
  end

end
