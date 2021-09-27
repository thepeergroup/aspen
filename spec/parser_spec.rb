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
      let(:code) { "(Jack) [is the boss of] (Person: Liz M. Lemon)" }
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

    context "lists" do
      let(:ast) { described_class.parse_code(code) }

      # Will need to look ahead to end of line after bracket.
      context "with grouping label" do
        context "with short form origin" do
          let(:code) {
            <<~ASPEN
              (Liz) [works with] (Writers):
                - Frank
                - Lutz
                - Toofer

              (Liz) [knows] (Jack).
            ASPEN
          }

          let(:statements) { ast.statements.first(3) }

          it "parses three statements (really 4)" do
            expect(statements.count).to eq(3)
          end

          # it "gets the right origin" do
          #   origin = statements.last.origin

          #   expect(origin.label.content.inner_content).to eq(nil)
          #   expect(origin.attribute.content.inner_content).to eq("Liz")
          # end

          # it "sets the right label" do
          #   label = statements.last.edge.content.inner_content
          #   expect(label).to eq("works with")
          # end

          # it "gets the right targets" do
          #   statements.each do |st|
          #     expect(st.target.label.content.inner_content).to eq("Writer")
          #   end

          #   names = statements.map { |st| st.target.attribute.content.inner_content }
          #   expect(names).to eq(["Frank", "Lutz", "Toofer"])
          # end
        end

        context "with grouping label" do
          let(:code) {
            <<~ASPEN
              (Person: Liz) [works with] (Writers):
                - Frank
                - Lutz
                - Toofer
            ASPEN
          }

          it "gets the right origin" do
            origin = ast.statements.last.origin

            expect(origin.label.content.inner_content).to eq("Person")
            expect(origin.attribute.content.inner_content).to eq("Liz")
          end
        end
      end

      # context "with different labels" do
      #   let(:code) {
      #     <<~ASPEN
      #       (Liz) [works with]:
      #         * Tracy Jordan (Actor)
      #         * Jenna Maroney (Actor)
      #         * Peter "Pete" Hornberger (Producer)
      #     ASPEN
      #   }
      #   pending "parses" do
      #     expect(ast).to eq(nil)
      #   end
      # end

    end # lists
  end # statements
end
