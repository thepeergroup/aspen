MERGE (postoffice_02111:PostOffice { zipcode: "02111" })
MERGE (shipment_4aec5d:Shipment { tracking_number: "4aec5d" })
MERGE (postoffice_05443:PostOffice { zipcode: "05443" })
MERGE (shipment_001091:Shipment { tracking_number: "001091" })

MERGE (postoffice_02111)-[:SENT]->(shipment_4aec5d)
MERGE (postoffice_05443)-[:RECEIVED]->(shipment_001091)
