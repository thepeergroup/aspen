MERGE (person_matt:Person { name: "Matt" })
MERGE (person_alyssa:Person { name: "Alyssa" })
MERGE (person_joel:Person { name: "Joel" })

MERGE (person_matt)<-[:INCLUDES]-(intro_1:Introduction)-[:INCLUDES]->(person_alyssa)
MERGE (intro_1)-[:OCCURRED_AT]->(:Event { title: "Graphs4Good Kickoff" })
MERGE (person_matt)-[:KNOWS]-(person_alyssa)
MERGE (person_alyssa)<-[:INCLUDES]-(intro_2:Introduction)-[:INCLUDES]->(person_joel)
MERGE (intro_2)-[:OCCURRED_AT]->(:Event { title: "Graphs4Good Kickoff" })
MERGE (person_alyssa)-[:KNOWS]-(person_joel)
;
