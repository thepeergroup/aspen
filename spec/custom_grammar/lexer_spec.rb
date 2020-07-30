require 'aspen'

describe Aspen::CustomGrammar::Lexer do

  context "with a node and string" do
    let(:expr) { "(Person a) knows (string b)." }

    let(:tokens) {[
      [:OPEN_PARENS],
      [:TYPE, ["node", "Person"]],
      [:VAR_NAME, "a"],
      [:CLOSE_PARENS],
      [:BARE, " knows "],
      [:OPEN_PARENS],
      [:TYPE, "string"],
      [:VAR_NAME, "b"],
      [:CLOSE_PARENS],
      [:BARE, "."]
    ]}

    it "tokenizes" do
      expect(described_class.tokenize(expr)).to eq(tokens)
    end
  end

  context "with various numerics" do
    let(:expr) { "(integer a) relates to (float b), which relates to (numeric c)." }

    let(:tokens) {[
      [:OPEN_PARENS],
      [:TYPE, "integer"],
      [:VAR_NAME, "a"],
      [:CLOSE_PARENS],
      [:BARE, " relates to "],
      [:OPEN_PARENS],
      [:TYPE, "float"],
      [:VAR_NAME, "b"],
      [:CLOSE_PARENS],
      [:BARE, ", which relates to "],
      [:OPEN_PARENS],
      [:TYPE, "numeric"],
      [:VAR_NAME, "c"],
      [:CLOSE_PARENS],
      [:BARE, "."]
    ]}

    it "tokenizes" do
      expect(described_class.tokenize(expr)).to eq(tokens)
    end
  end
end
