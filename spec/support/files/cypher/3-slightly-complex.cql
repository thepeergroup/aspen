MERGE (person_liz:Person { name: "Liz" })
MERGE (person_jack:Person { name: "Jack" })
MERGE (employer_nbc_universal:Employer { company_name: "NBC Universal" })

MERGE (person_liz)-[:KNOWS]-(person_jack)
MERGE (person_liz)-[:WORKS_AT]->(employer_nbc_universal)
;
