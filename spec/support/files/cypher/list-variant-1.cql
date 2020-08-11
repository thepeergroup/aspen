MERGE (entity_karl:Entity { name: "Karl" })
MERGE (entity_matt:Entity { name: "Matt" })
MERGE (state_rhode_island:State { name: "Rhode Island" })
MERGE (state_massachusetts:State { name: "Massachusetts" })
MERGE (state_maine:State { name: "Maine" })
MERGE (job_consultant:Job { name: "Consultant" })

MERGE (entity_karl)-[:KNOWS]->(entity_matt)
MERGE (entity_karl)-[:KNOWS_ABOUT]->(state_rhode_island)
MERGE (entity_karl)-[:KNOWS_ABOUT]->(state_massachusetts)
MERGE (entity_karl)-[:KNOWS_ABOUT]->(state_maine)
MERGE (entity_karl)-[:HAS_JOB]->(job_consultant)
;
