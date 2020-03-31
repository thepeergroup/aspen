MERGE (person_jonathan:Person { name: "Jonathan" })
MERGE (person_jack_donaghy:Person { name: "Jack Donaghy" })
MERGE (organization_nbc:Organization { name: "NBC" })
MERGE (person_liz_lemon:Person { name: "Liz Lemon" })

MERGE (person_jonathan)-[:WORKS_FOR { role: "personal assistant" }]->(person_jack_donaghy)
MERGE (person_jonathan)-[:WORKS_FOR]->(organization_nbc)
MERGE (person_jack_donaghy)-[:WORKS_FOR { role: "CEO" }]->(organization_nbc)
MERGE (person_liz_lemon)-[:WORKS_FOR { role: "TV Producer" }]->(organization_nbc)
MERGE (person_liz_lemon)-[:IS_FRIENDS_WITH { desc: "best" }]-(person_jack_donaghy)
;
