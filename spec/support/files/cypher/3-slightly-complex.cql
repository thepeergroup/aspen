MERGE (person_liz:Person { name: "Liz" })
MERGE (show_tgs_with_tracy_jordan:Show { title: "TGS with Tracy Jordan" })
MERGE (person_tracy:Person { name: "Tracy" })
MERGE (person_jenna:Person { name: "Jenna" })
MERGE (person_pete:Person { name: "Pete" })
MERGE (person_jack:Person { name: "Jack" })
MERGE (person_hank_hooper:Person { name: "Hank Hooper" })
MERGE (person_hank:Person { name: "Hank" })
MERGE (employer_kabletown:Employer { company_name: "Kabletown" })

MERGE (person_liz)-[:RUNS]->(show_tgs_with_tracy_jordan)
MERGE (person_tracy)-[:ACTS_IN]->(show_tgs_with_tracy_jordan)
MERGE (person_jenna)-[:ACTS_IN]->(show_tgs_with_tracy_jordan)
MERGE (person_pete)-[:PRODUCES]->(show_tgs_with_tracy_jordan)
MERGE (person_liz)-[:REPORTS_TO]->(person_jack)
MERGE (person_jack)-[:REPORTS_TO]->(person_hank_hooper)
MERGE (person_pete)-[:REPORTS_TO]->(person_liz)
MERGE (person_pete)-[:PLAYED_GUITAR_FOR]->(person_jack)
MERGE (person_hank)-[:RUNS]->(employer_kabletown)
MERGE (person_liz)-[:WORKS_AT]->(employer_kabletown)
