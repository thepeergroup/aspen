MERGE (entity_liz:Entity { name: "Liz" })
MERGE (entity_jack:Entity { name: "Jack" })
MERGE (entity_tracy:Entity { name: "Tracy" })
MERGE (entity_kenneth:Entity { name: "Kenneth" })

MERGE (entity_liz)-[:KNOWS]->(entity_jack)
MERGE (entity_tracy)-[:KNOWS]->(entity_kenneth)
