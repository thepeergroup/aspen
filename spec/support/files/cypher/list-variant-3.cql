MERGE (entity_karl:Entity { name: "Karl" })
MERGE (state_rhode_island:State { name: "Rhode Island" })
MERGE (commonwealth_massachusetts:Commonwealth { name: "Massachusetts" })
MERGE (state_maine:State { name: "Maine" })

MERGE (entity_karl)-[:KNOWS_ABOUT]->(state_rhode_island)
MERGE (entity_karl)-[:KNOWS_ABOUT]->(commonwealth_massachusetts)
MERGE (entity_karl)-[:KNOWS_ABOUT]->(state_maine)
