MERGE (person_liz:Person { name: "Liz", age: 36 })
MERGE (person_jack:Person { name: "Jack" })

MERGE (person_liz)-[:KNOWS]-(person_jack)
