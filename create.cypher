CREATE CONSTRAINT ON (a:Airport)
    ASSERT a.iata IS UNIQUE

CREATE CONSTRAINT ON (c:Country)
    ASSERT c.code IS UNIQUE

CREATE CONSTRAINT ON (s:State)
    ASSERT s.code IS UNIQUE

CREATE CONSTRAINT ON (r:Region)
    ASSERT r.code IS UNIQUE

---

LOAD CSV WITH HEADERS 
    FROM 'https://raw.githubusercontent.com/momiller121/airport_demo/master/airports.csv' 
    AS Airport

WITH Airport, replace(toUpper(Airport.regionName),' ','_') as regionName
MERGE (r:Region {code: regionName}) 
    SET r.code=regionName
    SET r.name=Airport.regionName

MERGE (c:Country {code: Airport.countryCode}) 
    SET c.code=Airport.countryCode
    SET c.name=Airport.countryName

MERGE (s:State {code: Airport.stateCode}) 
    SET s.code=Airport.stateCode
    SET s.name='MISSING'

MERGE (a:Airport {iata: Airport.iata}) 
    SET a=Airport
    REMOVE a.countryCode
    REMOVE a.stateCode
    REMOVE a.countryName

MERGE (s)-[:in_country]->(c)

MERGE (a)-[:in_state]->(s)
MERGE (a)-[:has_property]->(s)

MERGE (a)-[:in_country]->(c)
MERGE (a)-[:has_property]->(c)

MERGE (c)-[:in_region]->(r)
MERGE (c)-[:has_property]->(r)

---

WITH ['en','fr','de'] AS LANGS

MATCH (a) WHERE exists(a.name) // all names need translation
UNWIND LANGS as lang
MERGE (a)-[l:localized {lang:lang}]->(p:Property)
	SET p.lang=lang
    SET p.ready=false


