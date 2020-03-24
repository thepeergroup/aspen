require 'aspen'

describe Aspen do

  it "raises an error with an empty string" do
    expect { Aspen.compile_text(" ") }.to raise_error(Aspen::Error)
  end

  let (:simple_case) {
    <<~ASPEN
      default Person, name
      ----
      (Matt) [knows] (Brianna).
    ASPEN
  }

  let (:simple_case_cypher) {
    <<~CYPHER
      MERGE (person_matt:Person { name: "Matt" })
      MERGE (person_brianna:Person { name: "Brianna" })

      MERGE (person_matt)-[:KNOWS]->(person_brianna)
      ;
    CYPHER
  }

  it "renders simple Aspen" do
    expect(Aspen.compile_text(simple_case)).to eql(simple_case_cypher)
  end

  let (:case_two) {
    <<~ASPEN
      default Person, first_name
      ----
      (Eliza) [knows] (Brianna).
    ASPEN
  }

  let (:case_two_cypher) {
    <<~CYPHER
      MERGE (person_eliza:Person { first_name: "Eliza" })
      MERGE (person_brianna:Person { first_name: "Brianna" })

      MERGE (person_eliza)-[:KNOWS]->(person_brianna)
      ;
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
      ----
      (Matt) [knows] (Brianna)
      (Matt) [works at] (Employer, UMass Boston)
    ASPEN
  }

  let (:slightly_complex_with_line_break) {
    <<~ASPEN
      default Person, name
      default_attribute Employer, company_name
      reciprocal knows
      ----

      (Matt) [knows] (Brianna)

      (Matt) [works at] (Employer, UMass Boston)
    ASPEN
  }

  let (:slightly_complex_cypher) {
    <<~CYPHER
      MERGE (person_matt:Person { name: "Matt" })
      MERGE (person_brianna:Person { name: "Brianna" })
      MERGE (employer_umass_boston:Employer { company_name: "UMass Boston" })

      MERGE (person_matt)-[:KNOWS]-(person_brianna)
      MERGE (person_matt)-[:WORKS_AT]->(employer_umass_boston)
      ;
    CYPHER
  }

  it "renders slightly complex Aspen" do
    expect(Aspen.compile_text(slightly_complex)).to eql(slightly_complex_cypher)
    expect(Aspen.compile_text(slightly_complex_with_line_break)).to eql(slightly_complex_cypher)
  end

  let (:full_form) {
    <<~ASPEN
      default Person, name
      reciprocal knows
      ----

      (Person { name: "Matt", age: 31 }) [knows] (Brianna)
    ASPEN
  }

  let (:full_form_cypher) {
    <<~CYPHER
      MERGE (person_matt:Person { name: "Matt", age: 31 })
      MERGE (person_brianna:Person { name: "Brianna" })

      MERGE (person_matt)-[:KNOWS]-(person_brianna)
      ;
    CYPHER
  }

  it "renders full form Aspen" do
    expect(Aspen.compile_text(full_form)).to eql(full_form_cypher)
  end

  let (:typed_attrs) {
    <<~ASPEN
      default PollingPlace, voters
      ----

      (PollingPlace, 100) [outmarketed] (PollingPlace, 10)
    ASPEN
  }

  let (:typed_attrs_cypher) {
    <<~CYPHER
      MERGE (pollingplace_100:PollingPlace { voters: 100 })
      MERGE (pollingplace_10:PollingPlace { voters: 10 })

      MERGE (pollingplace_100)-[:OUTMARKETED]->(pollingplace_10)
      ;
    CYPHER
  }

  it "renders typed attributes when default" do
    expect(Aspen.compile_text(typed_attrs)).to eql(typed_attrs_cypher)
  end

  let (:typed_da_attrs) {
    <<~ASPEN
      default Person, name
      default_attribute PollingPlace, voters
      ----

      (PollingPlace, 100) [outmarketed] (PollingPlace, 10)
    ASPEN
  }

  let (:typed_da_attrs_cypher) {
    <<~CYPHER
      MERGE (pollingplace_100:PollingPlace { voters: 100 })
      MERGE (pollingplace_10:PollingPlace { voters: 10 })

      MERGE (pollingplace_100)-[:OUTMARKETED]->(pollingplace_10)
      ;
    CYPHER
  }

  it "renders typed attributes when default" do
    expect(Aspen.compile_text(typed_da_attrs)).to eql(typed_da_attrs_cypher)
  end


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

  let (:yoga_community_aspen) {
    <<~CYPHER
      default Person, name
      default_attribute Employer, company_name
      default_attribute Studio, company_name

      reciprocal knows, is friends with

      ----

      (Matt) [is friends with] (Brianna).
      (Matt) [is friends with] (Eliza).
      (Brianna) [is friends with] (Eliza).

      (Brianna) [knows] (Sarah).
      (Eliza) [knows] (Holland).
      (Sarah) [teaches at] (Studio, The Corner Studio)
      (Holland) [teaches at] (Studio, The Corner Studio)
      (Jenna) [owns] (Studio, The Corner Studio)
      (Jenna) [teaches at] (Studio, The Corner Studio)

      (Rebecca) [knows] (Jenna)
      (Rebecca) [is friends with] (Matt)
      (Rebecca) [is friends with] (Brianna)
      (Rebecca) [knows] (Eliza)
    CYPHER
  }

  let (:yoga_community_cypher) {
    <<~CYPHER
      MERGE (person_matt:Person { name: "Matt" })
      MERGE (person_brianna:Person { name: "Brianna" })
      MERGE (person_eliza:Person { name: "Eliza" })
      MERGE (person_sarah:Person { name: "Sarah" })
      MERGE (person_holland:Person { name: "Holland" })
      MERGE (studio_the_corner_studio:Studio { company_name: "The Corner Studio" })
      MERGE (person_jenna:Person { name: "Jenna" })
      MERGE (person_rebecca:Person { name: "Rebecca" })

      MERGE (person_matt)-[:IS_FRIENDS_WITH]-(person_brianna)
      MERGE (person_matt)-[:IS_FRIENDS_WITH]-(person_eliza)
      MERGE (person_brianna)-[:IS_FRIENDS_WITH]-(person_eliza)
      MERGE (person_brianna)-[:KNOWS]-(person_sarah)
      MERGE (person_eliza)-[:KNOWS]-(person_holland)
      MERGE (person_sarah)-[:TEACHES_AT]->(studio_the_corner_studio)
      MERGE (person_holland)-[:TEACHES_AT]->(studio_the_corner_studio)
      MERGE (person_jenna)-[:OWNS]->(studio_the_corner_studio)
      MERGE (person_jenna)-[:TEACHES_AT]->(studio_the_corner_studio)
      MERGE (person_rebecca)-[:KNOWS]-(person_jenna)
      MERGE (person_rebecca)-[:IS_FRIENDS_WITH]-(person_matt)
      MERGE (person_rebecca)-[:IS_FRIENDS_WITH]-(person_brianna)
      MERGE (person_rebecca)-[:KNOWS]-(person_eliza)
      ;
    CYPHER
  }

  it "renders yoga community Aspen to Cypher" do
    expect(Aspen.compile_text(yoga_community_aspen)).to eql(yoga_community_cypher)
  end


  # TODO: Catch that Jeanne and Jeanne Cleary are collisions
  # TODO: Check that there are no unreferenced variables in the templates.
  # TODO: Uncouple this from needing #default?, though it should need default_attribute

  let (:very_complex_aspen) {
    <<~ASPEN
      default Person, name
      default_attribute Organization, name

      match
        (Person a) is (Person b)'s (string r).
      to
        {{{a}}}-[:WORKS_FOR { role: {{{r}}} }]->{{{b}}}
      end

      match
        (Person p) works at (Organization org).
      to
        {{{p}}}-[:WORKS_FOR]->{{{org}}}
      end

      match
        (Person p) is the (string r) at (Organization org).
      to
        {{{p}}}-[:WORKS_FOR { role: {{{r}}} }]->{{{org}}}
      end

      match
        (Person p) and (Person q) are best friends.
      to
        {{{p}}}-[:IS_FRIENDS_WITH { desc: "best" }]-{{{q}}}
      end
      ----

      Sureya is Jeanne Cleary's "case manager".
      Sureya works at CDSC.
      Gail Packer is the "Executive Director" at CDSC.
      Gail Packer and Jeanne Cleary are best friends.
    ASPEN
  }

  let (:cypher_from_very_complex_aspen) {
    <<~CYPHER
      MERGE (person_sureya:Person { name: "Sureya" })
      MERGE (person_jeanne_cleary:Person { name: "Jeanne Cleary" })
      MERGE (organization_cdsc:Organization { name: "CDSC" })
      MERGE (person_gail_packer:Person { name: "Gail Packer" })

      MERGE (person_sureya)-[:WORKS_FOR { role: "case manager" }]->(person_jeanne_cleary)
      MERGE (person_sureya)-[:WORKS_FOR]->(organization_cdsc)
      MERGE (person_gail_packer)-[:WORKS_FOR { role: "Executive Director" }]->(organization_cdsc)
      MERGE (person_gail_packer)-[:IS_FRIENDS_WITH { desc: "best" }]-(person_jeanne_cleary)
      ;
    CYPHER
  }

  it "renders very complex Aspen" do
    expect(
      Aspen.compile_text(very_complex_aspen)
    ).to eql(
      cypher_from_very_complex_aspen
    )
  end

end
