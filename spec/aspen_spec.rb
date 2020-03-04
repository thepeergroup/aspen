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
      MERGE (person-matt:Person {name: "Matt"})
      , (person-brianna:Person {name: "Brianna"})

      , (person-matt)-[:KNOWS]->(person-brianna)
    CYPHER
  }

  it "renders simple Aspen" do
    expect(Aspen.compile_text(simple_case)).to eql(simple_case_cypher)
  end

  let (:case_two) {
    <<~ASPEN
      default Person, first_name
      (Eliza) [knows] (Brianna).
    ASPEN
  }

  let (:case_two_cypher) {
    <<~CYPHER
      MERGE (person-eliza:Person {first_name: "Eliza"})
      , (person-brianna:Person {first_name: "Brianna"})

      , (person-eliza)-[:KNOWS]->(person-brianna)
    CYPHER
  }

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

  let (:slightly_complex_with_line_break) {
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
      MERGE (person-matt:Person {name: "Matt"})
      , (person-brianna:Person {name: "Brianna"})
      , (employer-umass-boston:Employer {company_name: "UMass Boston"})

      , (person-matt)-[:KNOWS]-(person-brianna)
      , (person-matt)-[:WORKS_AT]->(employer-umass-boston)
    CYPHER
  }

  it "renders slightly complex Aspen" do
    expect(Aspen.compile_text(slightly_complex)).to eql(slightly_complex_cypher)
    expect(Aspen.compile_text(slightly_complex_with_line_break)).to eql(slightly_complex_cypher)
  end

  let (:very_complex_aspen) {
      <<~ASPEN
      map
        (Person a) is (Person b)'s (Role r).
      to
        (a)-[:WORKS_FOR {role: r}]->(b)

      map
        (Person p) works at (Organization org)
      to
        (p)-[:WORKS_FOR]->(org)

      map
        (Person p) is the (Role r) at (Organization org)
      to
        (p)-[:WORKS_FOR {role: r}]->(q)

      map
        (Person p) and (Person q) are best friends.
      to
        (a)-[:IS_FRIENDS_WITH {desc: "best"}]->(b)
        (b)-[:IS_FRIENDS_WITH {desc: "best"}]->(a)

      (Sureya) is (Jeanne)'s (case manager).
      (Sureya) works at (CDSC).
      (Gail Packer) is the (Executive Director) at (CDSC).
      (Gail Packer) and (Jeanne Cleary) are best friends.
    ASPEN
  }

  let (:very_complex_aspen_without_parens) {
    <<~ASPEN
      map
        (Person a) is (Person b)'s (Role r).
      to
        (a)-[:WORKS_FOR {role: r}]->(b)

      map
        (Person p) works at (Organization org)
      to
        (p)-[:WORKS_FOR]->(org)

      map
        (Person p) is the (Role r) at (Organization org)
      to
        (p)-[:WORKS_FOR {role: r}]->(q)

      map
        (Person p) and (Person q) are best friends.
      to
        (a)-[:IS_FRIENDS_WITH {desc: "best"}]->(b)
        (b)-[:IS_FRIENDS_WITH {desc: "best"}]->(a)

      Sureya is Jeanne Cleary's case manager.
      Sureya works at CDSC.
      Gail Packer is the Executive Director at CDSC.
      Gail Packer and Jeanne are best friends.
    ASPEN
  }

  let (:cypher_from_very_complex_aspen) {
    <<~CYPHER
      MERGE (sureya:Person {name: "Sureya"})
      , (jeanne:Person {name: "Jeanne Cleary"})
      , (gail:Person {name: "Gail Packer"})
      , (cdsc:Organization {name: "CDSC"})

      , (sureya)-[:WORKS_FOR {role: "case manager"}]->(jeanne)
      , (sureya)-[:WORKS_FOR]->(cdsc)
      , (gail)-[:WORKS_FOR {role: "Executive Director"}]->(cdsc)
      , (gail)-[:IS_FRIENDS_WITH {desc: "best"}]->(jeanne)
      , (jeanne)-[:IS_FRIENDS_WITH {desc: "best"}]->(gail)
    CYPHER
  }

  # pending "renders very complex Aspen" do
  #   expect(
  #     Aspen.compile_text(very_complex_aspen)
  #   ).to eql(
  #     cypher_from_very_complex_aspen
  #   )
  # end

  # pending "renders very complex Aspen without parentheses" do
  #   expect(
  #     Aspen.compile_text(very_complex_aspen_without_parens)
  #   ).to eql(
  #     cypher_from_very_complex_aspen
  #   )
  # end

end
