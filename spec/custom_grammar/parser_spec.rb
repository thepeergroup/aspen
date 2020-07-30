require 'aspen'

describe Aspen::CustomGrammar::Parser do

  let(:ast) { described_class.parse_code(expr, {}, Aspen::CustomGrammar::Lexer) }

  context "with a node and string" do
    let(:expr) { "(Person a) knows (string b)." }

    it "parses" do
      segment = ast.segments.first
      expect(segment).to be_a(Aspen::CustomGrammar::AST::Nodes::CaptureSegment)
      # TODO: May want to make Type a CustomGrammar node
      expect(segment.type).to eq(:node)
      expect(segment.label).to eq("Person")
      expect(segment.var_name).to eq("a")
    end
  end

  context "with various numerics" do
    let(:expr) { "(integer a) relates to (float b), which relates to (numeric c)." }

    it "parses" do
      expect(ast.segments[1]).to be_a(Aspen::CustomGrammar::AST::Nodes::Bare)

      segment = ast.segments[-2]
      expect(segment).to be_a(Aspen::CustomGrammar::AST::Nodes::CaptureSegment)
      # TODO: May want to make Type a CustomGrammar node
      expect(segment.type).to eq(:numeric)
      expect(segment.label).to be_nil
      expect(segment.var_name).to eq("c")
    end
  end

end
