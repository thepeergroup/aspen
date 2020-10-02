require 'aspen'

describe Aspen do

  it "raises an error with an empty string" do
    expect { Aspen.compile_text(" ") }.to raise_error(Aspen::Error)
  end

  context "code" do

    let (:aspen) do
      File.read "spec/support/files/aspen/#{filename}.aspen"
    end

    let (:cypher) do
      File.read "spec/support/files/cypher/#{filename}.cql"
    end

    context 'without discourse' do
      let(:filename) { '1-simple' }
      it 'renders' do
        expect(Aspen.compile_text(aspen)).to eql(cypher)
      end
    end

    context 'with discourse' do
      let(:filename) { '2-two' }
      it 'renders' do
        expect(Aspen.compile_text(aspen)).to eql(cypher)
      end
    end

    context 'with a discourse with :attributes, :reciprocal' do
      let(:filename) { '3-slightly-complex' }
      it 'renders' do
        expect(Aspen.compile_text(aspen)).to eql(cypher)
      end
    end

    # pending 'with Cypher form' do
    #   fail """
    #     Not yet implemented, thinking about skipping tokenizing Cypher
    #     as little as possible.
    #   """
    #   let(:filename) { '4-full-form' }
    #   it 'renders' do
    #     expect(Aspen.compile_text(aspen)).to eql(cypher)
    #   end
    # end

    context 'with implicitly typed attributes' do
      let(:filename) { '5-impl-typed-attrs' }
      it 'renders' do
        expect(Aspen.compile_text(aspen)).to eql(cypher)
      end
    end

    context 'with implicitly typed attributes, DA form' do
      let(:filename) { '6-impl-typed-da' }
      it 'renders' do
        expect(Aspen.compile_text(aspen)).to eql(cypher)
      end
    end

    context 'with a small network' do
      let(:filename) { '7-small-network' }
      it 'renders' do
        expect(Aspen.compile_text(aspen)).to eql(cypher)
      end
    end

    context 'with complex matchers' do
      let(:filename) { '8-with-matchers' }
      it 'renders' do
        expect(Aspen.compile_text(aspen)).to eql(cypher)
      end
    end

    context 'with protections' do
      context 'and an invalid label' do
        let(:filename) { 'protection-invalid-label' }
        it 'raises' do
          expect { Aspen.compile_text(aspen) }.to raise_error(Aspen::Error)
        end
      end

      context 'and an invalid edge' do
        let(:filename) { 'protection-invalid-edge' }
        it 'raises' do
          expect { Aspen.compile_text(aspen) }.to raise_error(Aspen::Error)
        end
      end

      context 'and valid content' do
        let(:filename) { 'protection-valid' }
        it 'renders' do
          expect(Aspen.compile_text(aspen)).to eql(cypher)
        end
      end
    end

    context 'lists' do
      context 'variant 1' do
        let(:filename) { 'list-variant-1' }
        it 'renders' do
          expect(Aspen.compile_text(aspen)).to eql(cypher)
        end
      end
      context 'variant 2' do
        let(:filename) { 'list-variant-2' }
        pending 'renders' do
          fail "not yet implemented"
          expect(Aspen.compile_text(aspen)).to eql(cypher)
        end
      end
      context 'variant 3' do
        let(:filename) { 'list-variant-3' }
        pending 'renders' do
          fail "not yet implemented"
          expect(Aspen.compile_text(aspen)).to eql(cypher)
        end
      end
    end

    context 'unique nicknames' do
      let(:filename) { 'unique-nicknames' }
      it 'renders' do
        expect(Aspen.compile_text(aspen)).to eql(cypher)
      end
    end
  end

  # pending "minimal Aspen (just a node) compiles" do
  #   fail "Statements are presently required to be origin, edge, target"
  #   expect(Aspen.compile_text("(Liz)")).to eql("MERGE (entity_liz:Entity { name: \"Liz\" })")
  # end

  # pending "renders Aspen with non-annotated text" do
  #   fail
  #   aspen = "On this day, (Matt) was [interviewed by] (Mia), and it went well."
  #   cypher = <<~CYPHER
  #     MERGE (person_matt:Entity { name: "Matt" })
  #     MERGE (person_mia:Entity { name: "Mia" })

  #     MERGE (person_matt)-[:INTERVIEWED_BY]->(person_mia)
  #   CYPHER

  #   expect(Aspen.compile_text(aspen)).to eql(cypher)
  # end

  # TODO: In file 8, catch that Jack and Jack Donaghy are collisions
  # TODO: Uncouple this from needing #default?, though it should need default_attribute

  # let (:attribute_collision) {
  #   <<~ASPEN
  #   default Person, name
  #   reciprocal knows
  #   ----

  #   (Person { name: "Matt", age: 31 }) [knows] (Matt)
  #   ASPEN
  # }

  # pending "raises when attributes collide" do
  #   fail "This depends on Cypher form passing."
  #   expect {
  #     Aspen.compile_text(attribute_collision)
  #   }.to raise_error(Aspen::AttributeCollisionError)
  # end

end
