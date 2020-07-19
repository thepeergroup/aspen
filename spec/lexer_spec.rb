require 'aspen'

describe Aspen::Lexer do

  context "vanilla" do

    context "node" do
      context "with short form" do
        let(:code) { "(Liz M. Lemon)" }
        let(:tokens) { [
          [:OPEN_PARENS],
          [:CONTENT, "Liz M. Lemon"],
          [:CLOSE_PARENS]
        ]}
        it "tokenizes" do
          expect(described_class.tokenize(code)).to eq(tokens)
        end
      end

      context "with grouped form" do
        let(:code) { "(Person, Liz M. Lemon)" }
        let(:tokens) { [
          [:OPEN_PARENS],
          [:LABEL, "Person"],
          [:SEPARATOR, ","],
          [:CONTENT, "Liz M. Lemon"],
          [:CLOSE_PARENS]
        ] }
        it "tokenizes" do
          expect(described_class.tokenize(code)).to eq(tokens)
        end
      end

      context "with cypher form" do
        let(:codes) {[
          '(Person { name: "Liz M. Lemon", age: 36 })',
          '(:Person { name: "Liz M. Lemon", age: 36 })',
        ]}
        let(:tokens) { [
          [:OPEN_PARENS],
          [:LABEL, "Person"],
          [:OPEN_BRACES],
          [:IDENTIFIER, "name"],
          [:SEPARATOR, ":"],
          [:STRING, "Liz M. Lemon"],
          [:SEPARATOR, ","],
          [:IDENTIFIER, "age"],
          [:SEPARATOR, ":"],
          [:NUMBER, "36"],
          [:CLOSE_BRACES],
          [:CLOSE_PARENS]
        ] }
        it "tokenizes and tolerates Cypher-style labels" do
          codes.each do |code|
            expect(described_class.tokenize(code)).to eq(tokens)
          end
        end
      end
    end # node

    context "statements" do

      context "simple relationship" do
        let(:code) { "(Liz) [knows] (Jack)." }
        let(:tokens) { [
          [:OPEN_PARENS],
          [:CONTENT, "Liz"],
          [:CLOSE_PARENS],
          [:OPEN_BRACKETS],
          [:CONTENT, "knows"],
          [:CLOSE_BRACKETS],
          [:OPEN_PARENS],
          [:CONTENT, "Jack"],
          [:CLOSE_PARENS],
          [:END_STATEMENT, "."]
        ] }
        it "tokenizes" do
          expect(described_class.tokenize(code)).to eq(tokens)
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

          let(:tokens) { [
            [:OPEN_PARENS],
            [:CONTENT, "Liz"],
            [:CLOSE_PARENS],
            [:OPEN_BRACKETS],
            [:CONTENT, "works with"],
            [:CLOSE_BRACKETS],
            [:OPEN_PARENS],
            [:CONTENT, "Writers"],
            [:CLOSE_PARENS],
            [:START_LIST, ":\n"],
            [:BULLET, "-"],
            [:CONTENT, "Frank"],
            [:BULLET, "-"],
            [:CONTENT, "Lutz"],
            [:BULLET, "-"],
            [:CONTENT, "Toofer"]
          ] }
          it "tokenizes" do
            expect(described_class.tokenize(code)).to eq(tokens)
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
          let(:tokens) { [
            [:OPEN_PARENS],
            [:CONTENT, "Liz"],
            [:CLOSE_PARENS],
            [:OPEN_BRACKETS],
            [:CONTENT, "works with"],
            [:CLOSE_BRACKETS],
            [:START_LIST, ":\n"],
            [:BULLET, "*"],
            [:CONTENT, "Tracy Jordan"],
            [:OPEN_PARENS],
            [:CONTENT, "Actor"],
            [:CLOSE_PARENS],
            [:BULLET, "*"],
            [:CONTENT, "Jenna Maroney"],
            [:OPEN_PARENS],
            [:CONTENT, "Actor"],
            [:CLOSE_PARENS],
            [:BULLET, "*"],
            [:CONTENT, "Peter \"Pete\" Hornberger"],
            [:OPEN_PARENS],
            [:CONTENT, "Producer"],
            [:CLOSE_PARENS]
          ] }
          it "tokenizes" do
            expect(described_class.tokenize(code)).to eq(tokens)
          end
        end

        context "invalid" do
          context "with different labels and malformed labels" do
            let(:code) {
              <<~ASPEN
                (Liz) [works with]:
                  * Peter "Pete" Hornberger (Executive Producer)
              ASPEN
            }
            # TODO: Better error message
            it "raises" do
              expect {
                described_class.tokenize(code)
              }.to raise_error(Aspen::ParseError)
            end
          end
        end

      end # lists
    end # statements

  end # vanilla
end
