MERGE (person_liz:Person { name: "Liz" })
MERGE (person_jack:Person { name: "Jack" })

MERGE (person_liz)-[:KNOWS]->(person_jack)
;
