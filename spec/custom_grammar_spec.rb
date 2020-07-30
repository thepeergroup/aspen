# SMELL: "compiles AND matches" (emphasis mine) tells me that this class
# and test are trying to do two things.

require 'aspen'

describe Aspen::CustomGrammar do

  let(:pattern) { described_class.compile_pattern(expr) }

  context "with a node and string" do
    let(:expr) { "(Person a) knows (string b)." }
    context "with valid matching statements" do
      [
        "Jack knows \"business topics\"."
      ].each do |statement|
        it "compiles and matches" do
          expect(pattern).to match(statement)
        end
      end
    end
  end

  context "with various numerics" do
    let(:expr) { "(integer a) relates to (float b), which relates to (numeric c)." }

    context "with valid matching statements" do
      it "compiles and matches" do
        [
          "1 relates to 1.0, which relates to 1.00", # int, float, numeric:float
          "1 relates to 1.0, which relates to 2"     # int, float, numeric:int
        ].each do |statement|
          expect(pattern).to match(statement)
        end
      end
    end

    context "with erroneous non-matching statements" do
      it "compiles and matches" do
        [
          "1.0 relates to 2, which relates to 3.00", # [float], float, numeric:float
          "1 relates to 2, which relates to 3"       # int,     [int], numeric:int
        ].each do |statement|
          expect(pattern).to_not match(statement)
        end
      end
    end
  end

end
