require 'aspen'

describe Aspen::Configuration do

  context "individual lines" do

    let (:default) { "default Person, name" }

    it "configures a valid default" do
      config = Aspen::Configuration.new(default)
      expect(config.default_node_label).to eql("Person")
      expect(config.default_node_attr_name).to eql("name")
      expect(config.default_attr_name_for_label("Person")).to eql("name")
    end

    let (:default_attribute) { "default_attribute Employer, company_name" }

    it "configures a default attribute for the given label" do
      config = Aspen::Configuration.new(default_attribute)
      expect(config.default_attr_name_for_label("Employer")).to eql("company_name")

      expect {
        config.default_attr_name_for_label("Person")
      }.to raise_error(Aspen::ConfigurationError)
    end

    let (:reciprocal) { "reciprocal knows, is friends with" }

    it "configures reciprocal relationships" do
      config = Aspen::Configuration.new(reciprocal)
      expect(config.reciprocal).to eq(["knows", "is friends with"])
    end

  end

  let (:together) {
    # Keep the blank line between "default_attribute" and "reciprocal".
    # We're making sure the configuration can handle blank lines.
    Aspen::Configuration.new(
      <<~ASPEN
        default Person, name
        default_attribute Employer, company_name

        reciprocal knows
      ASPEN
    )
  }

  it "configures a slightly complex valid default" do
    expect(together.default_node_label).to eql("Person")
    expect(together.default_node_attr_name).to eql("name")
    expect(together.default_attr_name_for_label("Employer")).to eql("company_name")
    expect(together.default_attr_name_for_label("Person")).to eql("name")
    expect(together.reciprocal_relationships).to eql(["knows"])

    expect(together.reciprocal?("knows")).to be true
  end

  context "invalid" do

    let (:no_comma) { "default Person name" }
    let (:default_bad_label) { "default Person Of Interest, name" }
    let (:default_bad_attr_name) { "default Person, first name" }

    it "raises with a no comma" do
      expect {
        Aspen::Configuration.new(no_comma)
      }.to raise_error(Aspen::ConfigurationError)
    end

    it "raises with a bad label" do
      expect {
        Aspen::Configuration.new(default_bad_label)
      }.to raise_error(Aspen::ConfigurationError)
    end

    it "raises with a bad attribute name" do
      expect {
        Aspen::Configuration.new(default_bad_attr_name)
      }.to raise_error(Aspen::ConfigurationError)
    end

    let (:default_attribute_bad_label) {
      "default_attribute Employer Aka The Man, company_name"
    }

    let (:default_attribute_bad_attr_name) {
      "default_attribute Employer, name of company"
    }

    it "raises with a bad attribute name" do
      expect {
        Aspen::Configuration.new(default_attribute_bad_label)
      }.to raise_error(Aspen::ConfigurationError)
    end

    it "raises with a bad attribute name" do
      expect {
        Aspen::Configuration.new(default_attribute_bad_attr_name)
      }.to raise_error(Aspen::ConfigurationError)
    end

    let (:bad_starting_tokens) {
      ["boop boop de doop", "config", "defaults", "default_attribut"]
    }

    it "raises with a bad starting token" do
      bad_starting_tokens.each do |line|
        expect {
          Aspen::Configuration.new(line)
        }.to raise_error(Aspen::ConfigurationError)
      end
    end

    it "raises with soon to be implemented options" do
      %w( allow require implicit ).each do |line|
        expect {
          Aspen::Configuration.new(line)
        }.to raise_error(Aspen::ConfigurationError)
      end
    end
  end

  context "load custom grammars" do

    let(:config) { Aspen::Configuration.new(match_block) }

    context "with a single match line" do

      let(:match_block) {
        <<~ASPEN
          match
            (Person a) gave a donation to (Person B).
          to
            {{a}}-[:GAVE_DONATION]->{{b}}
          end
        ASPEN
      }

      let(:line) { "Matt gave a donation to Hélène." }

      it "builds one matcher" do
        expect(config.grammar).to be_an(Aspen::Grammar)
        expect(config.grammar.count).to eq(1)
        expect(config.grammar.match?(line)).to be true
      end
    end

    context "with single-line matchers" do

      let(:match_block) {
        <<~ASPEN
          match
            (Person a) gave a donation to (Person B).
            (Person a) donated to (Person B).
          to
            {{a}}-[:GAVE_DONATION]->{{b}}
          end
        ASPEN
      }

      it "builds two matchers" do
        expect(config.grammar.count).to eq(2)
        expect(config.grammar.match?("Matt gave a donation to Hélène.")).to be true
        expect(config.grammar.match?("Matt donated to Hélène.")).to be true
      end
    end

    context "with a multiline template" do
      let(:match_block) {
        <<~ASPEN
          match
            (Person p) (string freq) attends (Class class) with (Person teacher) at (Studio studio)
          to
            {{{p}}}-[:ATTENDS { frequency: {{{freq}}} }]->{{{class}}}<-[:TEACHES]-{{{teacher}}}
            {{{class}}}-[:HOSTED_AT]->{{{studio}}}
          end
        ASPEN
      }

      let (:sentence) {
        "Matt \"regularly\" attends Meditation with Holland at Corner Studio."
      }

      it "builds one matchers" do
        expect(config.grammar.count).to eq(1)
        expect(config.grammar.match?(sentence)).to be true
      end
    end
  end
end


# config = <<~CONFIG
#       default Person, name
#       match
#         - (Person a) gave (Person b) $(numeric amt).
#         - (Person a) donated $(float amt) to (Person b).
#       to
#         "{{{a}}}-[:GAVE_DONATION]->(:Donation { amount: {{amt}} })<-[:RECEIVED_DONATION]-{{{b}}}"
#     CONFIG
