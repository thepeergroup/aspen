MERGE (pollingplace_100:PollingPlace { voters: 100 })
MERGE (pollingplace_10:PollingPlace { voters: 10 })

MERGE (pollingplace_100)-[:OUTMARKETED]->(pollingplace_10)
