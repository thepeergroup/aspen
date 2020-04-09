require 'aspen'

describe Aspen::Parser do

  context "node" do
    context "with short form" do
      let(:code) { "(Liz M. Lemon)" }
      let(:node) { Aspen::AST::Nodes::Node }

      it "parses" do
        res = described_class.parse_code(code)
        expect(res.statements.first).to be_a(node)
      end
    end

    context "with grouped form" do
      let(:code) { "(Person, Liz M. Lemon)" }
      it "parses" do
        res = described_class.parse_code(code)
        expect(res.statements.first).to be_a(node)
      end
    end

    context "with cypher form" do
      let(:code) { '(:Person { name: "Liz M. Lemon", age: 36 })' }
      it "parses" do
        res = described_class.parse_code(code)
        expect(res.statements.first).to be_a(node)
      end
    end
  end # node

  context "statements" do

    context "simple relationship" do
      let(:code) { "(Liz) [knows] (Jack)." }
      let(:ast) { }
      pending "parses" do
        expect(described_class.parse_code(code)).to eq(ast)
      end
    end

    context "lists" do

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
