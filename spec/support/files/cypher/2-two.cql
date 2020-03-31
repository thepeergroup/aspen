MERGE (person_liz:Person { first_name: "Liz" })
MERGE (person_pete_hornberger:Person { first_name: "Pete Hornberger" })

MERGE (person_liz)-[:KNOWS]->(person_pete_hornberger)
;
