MERGE (entity_liz:Entity { name: "Liz" })
MERGE (entity_jack:Entity { name: "Jack" })

MERGE (entity_liz)-[:KNOWS]->(entity_jack)
;
