require 'aspen'

describe Aspen::Discourse do

  let(:some_labels) { %w( Entity Person PollingPlace ) }
  let(:some_edges) {['knows', 'is friends with', 'loves']}

  context "valid" do

    context "file types" do
      let(:yaml) { <<~EOS
        default:
          label: Person
        EOS
      }
      let(:hash) { YAML.load(yaml) }

      it "loads YAML" do
        expect(described_class.from_yaml(yaml)).to be_an Aspen::Discourse
      end

      it "loads hashes" do
        expect(described_class.from_hash(hash)).to be_an Aspen::Discourse
      end
    end # / file types

    context "unconfigured" do
      let(:discourse) { described_class.new }

      it "#default_label" do
        expect(discourse.default_label).to eq("Entity")
      end

      it "#default_attr_name" do
        some_labels.each do |label|
          expect(discourse.default_attr_name(label)).to eq("name")
        end
      end

      it "#allows_label?" do
        expect(discourse.allows_label?(some_labels.sample)).to be true
      end

      it "#allows_edge?" do
        expect(discourse.allows_edge?(some_edges.sample)).to be true
      end

      it "#reciprocal?" do
        expect(discourse.reciprocal?(some_edges.sample)).to be false
      end
    end #  / unconfigured

    context "configured" do

      let (:discourse) { described_class.from_yaml(config) }

      context "with a default label" do
        let (:config) {
          <<~EOS
          default:
            label: Person
          EOS
        }

        it "#default_label" do
          expect(discourse.default_label).to eq("Person")
        end

        it "#default_attribute" do
          expect(discourse.default_attr_name("Person")).to eq("name")
        end
      end

      context "with an untyped attribute" do
        let (:config) { <<~EOS
          default:
            label: Person
            attribute: age
          EOS
        }

        it "#default_label" do
          expect(discourse.default_label).to eq("Person")
        end

        it "sets #default_attribute for all labels" do
          expect(discourse.default_attr_name("Person")).to eq("age")
          expect(discourse.default_attr_name("AnyOtherLabel")).to eq("age")
        end

        context "with default attributes" do
          let (:config) do
            <<~EOS
              default:
                label: Person
                attributes:
                  Person: age
            EOS
          end

          it "#default_label" do
            expect(discourse.default_label).to eq("Person")
          end

          it "sets #default_attribute for Person" do
            expect(discourse.default_attr_name("Person")).to eq("age")
          end

          it "sets #default_attribute for all other labels" do
            expect(
              discourse.default_attr_name("HeckinHeck")
            ).to eq("name")
          end
        end # / with default atttributes
      end # /untyped

      context "with a typed attribute" do
        pending "it sets a typed default attribute"
      end # /typed

      context "with protected nodes" do
        let (:config) { <<~EOS
          allow_only:
            nodes: Entity, Person, PollingPlace
          EOS
        }
        it "#allows_label?" do
          expect(discourse.allows_label?("Entity")).to be true
          expect(discourse.allows_label?("Friend")).to be false
        end
      end

      context "with protected relationships" do
        let (:config) { <<~EOS
          allow_only:
            edges: knows, founded company with
          EOS
        }
        it "#allows_edge?" do
          expect(discourse.allows_edge?("knows")).to be true
          expect(discourse.allows_edge?("is friends with")).to be false
        end
      end

      context "with reciprocal relationships" do
        let (:config) { "reciprocal: knows" }
        it "#reciprocal?" do
          expect(discourse.reciprocal?("knows")).to be true
          expect(discourse.reciprocal?("hangs out with")).to be false
        end
      end

    end # /configured

    context "custom grammars" do
      let (:discourse) { described_class.from_yaml(config) }
      let (:config) {
        <<~YAML
          grammar:
            -
              match:
                - (Person a) gave a donation to (Person B).
              template: "{{{a}}}-[:GAVE_DONATION]->{{{b}}}"
        YAML
      }
      # let (:config) {
      #   { grammar: [{ match: matchers, template: template }] }
      # }
      # let (:matchers) { ["(Person a) gave a donation to (Person B)."] }
      # let (:template) { "{{{a}}}-[:GAVE_DONATION]->{{{b}}}" }

      let(:line) { "Matt gave a donation to Hélène." }

      context "with a one-line matcher" do
        it "builds a matcher" do
          expect(discourse.grammar).to be_a Aspen::CustomGrammar::Grammar
          expect(discourse.grammar.count).to eq 1
          expect(discourse.grammar.match?(line)).to be true
        end
      end

      context "with bulleted matchers" do
        let (:config) {
          <<~YAML
            grammar:
              -
                match:
                  - (Person a) gave a donation to (Person B).
                  - (Person a) donated to (Person B).
                template: |
                  {{{a}}}-[:GAVE_DONATION]->{{{b}}}
                  {{{a}}}-[:KNOWS_ABOUT]->{{{b}}}
          YAML
        }
        it "builds two matchers" do
          expect(discourse.grammar.count).to eq(2)
          expect(discourse.grammar.match?("Matt gave a donation to Hélène.")).to be true
          expect(discourse.grammar.match?("Matt donated to Hélène.")).to be true
        end
      end

    end # / custom grammars

  end # /valid
end
