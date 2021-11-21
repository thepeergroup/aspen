# (Entity)-[KNOWS]->(Entity)

{batch: [
  {from:"Liz",to:"Jack"},
]}

UNWIND $batch as row
MATCH (from:Entity {name: row.from})
MATCH (to:Entity {name: row.to})
MERGE (from)-[:KNOWS]->(to)
