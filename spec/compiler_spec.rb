require 'aspen'

describe Aspen::Compiler do

  let (:code)   { "(Liz) [knows] (Jack)." }
  let (:env)    { environment.merge({ reciprocal: "knows" }) }
  let (:tokens) { Aspen::Lexer.tokenize(code, env) }
  let (:ast)    { Aspen::Parser.parse(tokens, env) }
  let (:result) { Aspen::Compiler.new(ast, env).render }

  context 'Cypher adapter (default)' do
    let (:environment) { { adapter: :cypher } }
    it 'renders Cypher' do
      expect(result).to eq(
      <<~CYPHER
        MERGE (entity_liz:Entity { name: "Liz" })
        MERGE (entity_jack:Entity { name: "Jack" })

        MERGE (entity_liz)-[:KNOWS]-(entity_jack)
        ;
      CYPHER
      )
    end
  end

  context 'JSON adapter' do
    let (:environment) { { adapter: :json } }
    it 'renders JSON' do
      expected = '{"nodes":[{"name":"Liz","id":"entity_liz","label":"Entity"},{"name":"Jack","id":"entity_jack","label":"Entity"}],"edges":[{"id":"e0","source":"entity_liz","target":"entity_jack","label":"knows","reciprocal":true}]}'
      expect(result).to eq(expected)
    end
  end

  context 'GEXF adapter' do
    let (:environment) { { adapter: :gexf } }
    it 'renders GEXF' do
      expect(result).to eq(
        <<~GEXF
          <gexf xmlns="http://www.gexf.net/1.2draft" version="1.2">
              <graph mode="static" defaultedgetype="directed">
                  <nodes>
                      <node id="entity_liz" label="Entity" name="Liz">
                      <node id="entity_jack" label="Entity" name="Jack">
                  </nodes>
                  <edges>
                      <edge id="0" source="entity_liz" target="entity_jack" label="knows">
                  </edges>
              </graph>
          </gexf>
        GEXF
      )
    end
  end

end

