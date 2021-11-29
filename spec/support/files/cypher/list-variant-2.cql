MERGE (entity_karl:Entity { name: "Karl" })
MERGE (commonwealth_massachusetts:Commonwealth { name: "Massachusetts" })
MERGE (state_rhode_island:State { name: "Rhode Island" })
MERGE (commonwealth_pennsylvania:Commonwealth { name: "Pennsylvania" })

MERGE (entity_karl)-[:KNOWS_ABOUT]->(commonwealth_massachusetts)
MERGE (entity_karl)-[:KNOWS_ABOUT]->(state_rhode_island)
MERGE (entity_karl)-[:KNOWS_ABOUT]->(commonwealth_pennsylvania)
