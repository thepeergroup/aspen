MERGE (person_liz:Person { name: "Liz" })
MERGE (employer_kabletown:Employer { name: "Kabletown" })
MERGE (person_jack:Person { name: "Jack" })

MERGE (person_liz)-[:WORKS_AT]->(employer_kabletown)
MERGE (person_liz)-[:KNOWS]->(person_jack)
