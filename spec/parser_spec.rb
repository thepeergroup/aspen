require 'aspen'

describe Aspen::Parser do

  # We're doing full statements because partial parses, that is,
  # just parsing an edge or a node, are functionally meaningless
  # in relational databases. Full statements only.
  # (Maybe node partial parses in the future, but, meh.)
  context "node" do

    let(:node) { Aspen::AST::Nodes::Node }

    context "with short form" do
      let(:code) { "(Liz M. Lemon) [knows] (Jack)" }

      it "parses" do
        res = described_class.parse_code(code)
        expect(res.statements.first.origin).to be_a(node)
      end
    end

    context "with grouped form" do
      let(:code) { "(Jack) [is the boss of] (Person, Liz M. Lemon)" }
      it "parses" do
        res = described_class.parse_code(code)
        expect(res.statements.first.target).to be_a(node)
      end
    end

    pending "with cypher form" do
      fail "Not yet implemented"
      let(:code) { '(:Person { name: "Liz M. Lemon", age: 36 }) [knows] (Jack)' }
      it "parses" do
        res = described_class.parse_code(code)
        expect(res.statements.first.origin).to be_a(node)
      end
    end
  end # node

  context "statements" do

    context "simple relationship" do
      let(:code) { "(Liz) [knows] (Jack)." }
      let(:ast) { described_class.parse_code(code) }

      it "parses" do
        expect(ast.statements.count).to eq(1)
        origin = ast.statements.first.origin
        expect(origin.attribute.content.inner_content).to eq("Liz")
        expect(origin.label.content.inner_content).to be_nil
      end
    end

    # TODO: Change "pending" to "context" to start doing list statements.
    pending "lists" do

      # Will need to look ahead to end of line after bracket.
      context "with same label" do
        let(:code) {
          <<~ASPEN
            (Liz) [works with] (Writers):
              - Frank
              - Lutz
              - Toofer

          ASPEN
        }

        let(:ast) { }
        pending "parses" do
          expect(described_class.parse_code(code)).to eq(ast)
        end
      end

      context "with different labels" do
        let(:code) {
          <<~ASPEN
            (Liz) [works with]:
              * Tracy Jordan (Actor)
              * Jenna Maroney (Actor)
              * Peter "Pete" Hornberger (Producer)
          ASPEN
        }
        let(:ast) { }
        pending "parses" do
          expect(described_class.parse_code(code)).to eq(ast)
        end
      end

    end # lists
  end # statements
end
