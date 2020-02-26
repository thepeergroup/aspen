require 'aspen'

describe Aspen do

  let (:simple_case) {
    <<~ASPEN
      default Person, name
      (Matt) [knows] (Brianna).
    ASPEN
  }

  let (:simple_case_cypher) {
    <<~CYPHER
      MERGE (matt:Person {name: "Matt"})
      , (brianna:Person {name: "Brianna"})

      , (matt)-[:KNOWS]->(brianna)
    CYPHER
  }

  let (:case_two) {
    <<~ASPEN
      default Person, first_name
      (Eliza) [knows] (Brianna).
    ASPEN
  }

  let (:case_two_cypher) {
    <<~CYPHER
      MERGE (eliza:Person {first_name: "Eliza"})
      , (brianna:Person {first_name: "Brianna"})

      , (eliza)-[:KNOWS]->(brianna)
    CYPHER
  }

  it "renders simple Aspen" do
    expect(Aspen.compile_text(simple_case)).to eql(simple_case_cypher)
  end

  it "renders different simple Aspen" do
    expect(Aspen.compile_text(case_two)).to eql(case_two_cypher)
  end

  let (:slightly_complex) {
    <<~ASPEN
      default Person, name
      default_attribute Employer, company_name
      reciprocal knows

      (Matt) [knows] (Brianna)
      (Matt) [works at] (Employer, UMass Boston)
    ASPEN
  }

  let (:slightly_complex_cypher) {
    <<~CYPHER
      MERGE (person-matt:Person { name: "Matt" } )
      , (person-brianna:Person { name: "Brianna" } )
      , (employer-umass-boston:Employer { company_name: "UMass Boston" } )

      , (person-matt)-[:KNOWS]->(person-brianna)
      , (person-matt)<-[:KNOWS]-(person-brianna)
      , (person-matt)-[:WORKS_AT]->(employer-umass-boston)
    CYPHER
  }

  it "renders slightly complex Aspen" do
    expect(Aspen.compile_text(slightly_complex)).to eql(slightly_complex_cypher)
  end

end
