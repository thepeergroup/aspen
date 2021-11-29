// (Entity)-[KNOWS]->(Entity)

WITH [
  {from: "Liz", to: "Jack"},
  {from: "Tracy", to: "Kenneth"}
] as values

UNWIND values as row
MERGE (from:Entity {name: row.from})
MERGE (to:Entity {name: row.to})
MERGE (from)-[:KNOWS]->(to)
