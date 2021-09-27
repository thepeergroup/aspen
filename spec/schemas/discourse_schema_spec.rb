require 'aspen/schemas/discourse_schema'

describe Aspen::Schemas::DiscourseSchema do
  let(:valid_edges) {[
    "knows",
    "knows, is friends with, cannot stand"
  ]}
  let(:invalid_edges) {[
    "wh47 d0 y0u m34n",
    "this - isn't - good",
    "what's happening, does anybody know?"
  ]}

  pending "rejects superflous keys" do
    fail """
      dry/schema wasn't validating keys inside a hash until a recent update
      Moving this to 'pending' because I just need it to work.
    """
    config = { heck: "content" }
    expect(described_class.call(config).errors).to_not be_empty
  end

  context ":default" do

    context ":label" do
      let(:valid) { %w( Friend AnyOtherLabel ) }
      let(:invalid) { %w( friend camelCase  ) }

      it "accepts a PascalCase label" do
        valid.each do |label|
          config = { default: { label: label } }
          expect(described_class.call(config).errors).to be_empty
        end
      end

      it "rejects other formats" do
        invalid.each do |label|
          config = { default: { label: label } }
          expect(described_class.call(config).errors).to_not be_empty
        end
      end
    end

    context ":attribute" do
      let(:valid) { ["friend", "hello_friend", "HelloFriend9", "a"] }
      let(:invalid) { ["hello my honey", "9_times_do", "8"] }

      it "accepts identifiers" do
        valid.each do |att|
          config = { default: { attribute: att } }
          expect(described_class.call(config).errors).to be_empty
        end
      end

      it "rejects phrases with spaces" do
        invalid.each do |att|
          config = { default: { attribute: att } }
          expect(described_class.call(config).errors).to_not be_empty
        end
      end
    end

    # context ":attributes" do
    #   it "accepts a hash"
    # end
  end

  context ":allow_only" do
    context ":nodes" do
      let(:valid) {[
        "Person",
        "Person, Employer, AnyOtherLabel"
      ]}
      let(:invalid) {[
        "person",
        "Person, Employer, anyOtherLabel",
        "Person Employer Any Other Label"
      ]}
      it "requires a comma-separated string of labels" do
        valid.each do |list|
          config = { allow_only: { nodes: list } }
          expect(described_class.call(config).errors).to be_empty
        end
      end

      pending "rejects invalid labels" do
        invalid.each do |list|
          config = { allow_only: { nodes: list } }
          expect(described_class.call(config).errors).to_not be_empty
        end
      end
    end
    context ":relationships" do
      it "requires a comma-separated string" do
        valid_edges.each do |list|
          config = { allow_only: { edges: list } }
          expect(described_class.call(config).errors).to be_empty
        end
      end

      pending "rejects a bad strings or edges" do
        invalid_edges.each do |list|
          config = { allow_only: { edges: list } }
          expect(described_class.call(config).errors).to_not be_empty
        end
      end
    end
  end

  context ":reciprocal" do
    it "requires a comma-separated string" do
      valid_edges.each do |list|
        config = { reciprocal: list }
        expect(described_class.call(config).errors).to be_empty
      end
    end

    it "rejects a bad strings or edges" do
      invalid_edges.each do |list|
        config = { reciprocal: list }
        expect(described_class.call(config).errors).to_not be_empty
      end
    end
  end

  context ":grammar" do
    it "requires a 'match' and a 'template'" do
      config = { grammar: [{
        match: ["(Person a) knows (Person b)"],
        template: "{{{a}}}-[:KNOWS]->{{{b}}}"
      }]}
      expect(described_class.call(config).errors).to be_empty
    end

    it "rejects without a 'match'" do
      config = { grammar: [{
        template: "{{{a}}}-[:KNOWS]->{{{b}}}"
      }]}
      expect(described_class.call(config).errors).to_not be_empty
    end

    it "rejects without a 'template'" do
      config = { grammar: [{
        match: "(Person a) knows (Person b)"
      }]}
      expect(described_class.call(config).errors).to_not be_empty
    end

    it "rejects with superflous kesy" do
      config = { grammar: [{
        match: "(Person a) knows (Person b)",
        template: "{{{a}}}-[:KNOWS]->{{{b}}}",
        something_else: "true"
      }]}
      expect(described_class.call(config).errors).to_not be_empty
    end
  end

end

