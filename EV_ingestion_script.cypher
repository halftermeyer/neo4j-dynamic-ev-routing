MATCH (n) DETACH DELETE n;
CREATE (paris:City {lat: 48.8566, lon: 2.3522, name: 'Paris'}),
 (lyon:City {lat: 45.7640, lon: 4.8357, name: 'Lyon'}),
 (marseille:City {lat: 43.2965, lon: 5.3698, name: 'Marseille'}),
 (bordeaux:City {lat: 44.8378, lon: -0.5792, name: 'Bordeaux'}),
 (strasbourg:City {lat: 48.5734, lon: 7.7521, name: 'Strasbourg'}),
 (lille:City {lat: 50.6292, lon: 3.0573, name: 'Lille'}),
 (toulouse:City {lat: 43.6047, lon: 1.4442, name: 'Toulouse'}),
 (nice:City {lat: 43.7102, lon: 7.2620, name: 'Nice'}),
 (nantes:City {lat: 47.2184, lon: -1.5536, name: 'Nantes'}),
 (montpellier:City {lat: 43.6108, lon: 3.8767, name: 'Montpellier'}),
 (rennes:City {lat: 48.1173, lon: -1.6778, name: 'Rennes'}),
 (reims:City {lat: 49.2583, lon: 4.0317, name: 'Reims'}),
 (grenoble:City {lat: 45.1885, lon: 5.7245, name: 'Grenoble'}),
 (dijon:City {lat: 47.3220, lon: 5.0415, name: 'Dijon'}),
 (lehavre:City {lat: 49.4938, lon: 0.1079, name: 'Le Havre'});

CREATE (cs1:ChargingStation {lat: 48.7566, lon: 2.4522, id: 'CS1', name: 'CS1', power_kw: 150}),
 (cs2:ChargingStation {lat: 45.8640, lon: 4.7357, id: 'CS2', name: 'CS2', power_kw: 200}),
 (cs3:ChargingStation {lat: 43.3965, lon: 5.4698, id: 'CS3', name: 'CS3', power_kw: 350}),
 (cs4:ChargingStation {lat: 44.7378, lon: -0.4792, id: 'CS4', name: 'CS4', power_kw: 100}),
 (cs5:ChargingStation {lat: 48.4734, lon: 7.8521, id: 'CS5', name: 'CS5', power_kw: 250}),
 (cs6:ChargingStation {lat: 50.5292, lon: 3.1573, id: 'CS6', name: 'CS6', power_kw: 150}),
 (cs7:ChargingStation {lat: 43.5047, lon: 1.5442, id: 'CS7', name: 'CS7', power_kw: 200}),
 (cs8:ChargingStation {lat: 43.6102, lon: 7.3620, id: 'CS8', name: 'CS8', power_kw: 300}),
 (cs9:ChargingStation {lat: 47.1184, lon: -1.4536, id: 'CS9', name: 'CS9', power_kw: 120}),
 (cs10:ChargingStation {lat: 43.5108, lon: 3.9767, id: 'CS10', name: 'CS10', power_kw: 180});

CREATE (c1:Car {id: 'Car5', battery_capacity_kwh: 56, efficiency_kwh_per_km: 0.19, current_soc_percent: 39});
CREATE (c2:Car {id: 'Car6', battery_capacity_kwh: 100, efficiency_kwh_per_km: 0.1, current_soc_percent: 75});

MATCH (a:City {name: 'Paris'}), (b:ChargingStation {id: 'CS1'}) CREATE (a)-[:ROAD {distance_km: 10.0, speed_limit_kph: 50}]->(b);
MATCH (a:City {name: 'Paris'}), (b:City {name: 'Lyon'}) CREATE (a)-[:ROAD {distance_km: 460.0, speed_limit_kph: 110}]->(b);
MATCH (a:City {name: 'Lyon'}), (b:ChargingStation {id: 'CS2'}) CREATE (a)-[:ROAD {distance_km: 15.0, speed_limit_kph: 60}]->(b);
MATCH (a:City {name: 'Lyon'}), (b:City {name: 'Marseille'}) CREATE (a)-[:ROAD {distance_km: 310.0, speed_limit_kph: 110}]->(b);
MATCH (a:City {name: 'Marseille'}), (b:ChargingStation {id: 'CS3'}) CREATE (a)-[:ROAD {distance_km: 12.0, speed_limit_kph: 50}]->(b);
MATCH (a:City {name: 'Marseille'}), (b:City {name: 'Nice'}) CREATE (a)-[:ROAD {distance_km: 190.0, speed_limit_kph: 100}]->(b);
MATCH (a:City {name: 'Bordeaux'}), (b:ChargingStation {id: 'CS4'}) CREATE (a)-[:ROAD {distance_km: 8.0, speed_limit_kph: 50}]->(b);
MATCH (a:City {name: 'Bordeaux'}), (b:City {name: 'Nantes'}) CREATE (a)-[:ROAD {distance_km: 320.0, speed_limit_kph: 110}]->(b);
MATCH (a:City {name: 'Strasbourg'}), (b:ChargingStation {id: 'CS5'}) CREATE (a)-[:ROAD {distance_km: 10.0, speed_limit_kph: 60}]->(b);
MATCH (a:City {name: 'Strasbourg'}), (b:City {name: 'Reims'}) CREATE (a)-[:ROAD {distance_km: 370.0, speed_limit_kph: 110}]->(b);
MATCH (a:City {name: 'Lille'}), (b:ChargingStation {id: 'CS6'}) CREATE (a)-[:ROAD {distance_km: 7.0, speed_limit_kph: 50}]->(b);
MATCH (a:City {name: 'Lille'}), (b:City {name: 'Paris'}) CREATE (a)-[:ROAD {distance_km: 220.0, speed_limit_kph: 110}]->(b);
MATCH (a:City {name: 'Toulouse'}), (b:ChargingStation {id: 'CS7'}) CREATE (a)-[:ROAD {distance_km: 9.0, speed_limit_kph: 50}]->(b);
MATCH (a:City {name: 'Toulouse'}), (b:City {name: 'Montpellier'}) CREATE (a)-[:ROAD {distance_km: 340.0, speed_limit_kph: 110}]->(b);
MATCH (a:City {name: 'Nice'}), (b:ChargingStation {id: 'CS8'}) CREATE (a)-[:ROAD {distance_km: 11.0, speed_limit_kph: 60}]->(b);
MATCH (a:City {name: 'Nice'}), (b:City {name: 'Marseille'}) CREATE (a)-[:ROAD {distance_km: 190.0, speed_limit_kph: 100}]->(b);
MATCH (a:City {name: 'Nantes'}), (b:ChargingStation {id: 'CS9'}) CREATE (a)-[:ROAD {distance_km: 6.0, speed_limit_kph: 50}]->(b);
MATCH (a:City {name: 'Nantes'}), (b:City {name: 'Rennes'}) CREATE (a)-[:ROAD {distance_km: 110.0, speed_limit_kph: 100}]->(b);
MATCH (a:City {name: 'Montpellier'}), (b:ChargingStation {id: 'CS10'}) CREATE (a)-[:ROAD {distance_km: 13.0, speed_limit_kph: 60}]->(b);
MATCH (a:City {name: 'Montpellier'}), (b:City {name: 'Toulouse'}) CREATE (a)-[:ROAD {distance_km: 340.0, speed_limit_kph: 110}]->(b);
MATCH (a:City {name: 'Rennes'}), (b:City {name: 'Le Havre'}) CREATE (a)-[:ROAD {distance_km: 250.0, speed_limit_kph: 110}]->(b);
MATCH (a:City {name: 'Reims'}), (b:City {name: 'Paris'}) CREATE (a)-[:ROAD {distance_km: 140.0, speed_limit_kph: 100}]->(b);
MATCH (a:City {name: 'Grenoble'}), (b:City {name: 'Lyon'}) CREATE (a)-[:ROAD {distance_km: 100.0, speed_limit_kph: 100}]->(b);
MATCH (a:City {name: 'Dijon'}), (b:City {name: 'Strasbourg'}) CREATE (a)-[:ROAD {distance_km: 300.0, speed_limit_kph: 110}]->(b);
MATCH (a:City {name: 'Le Havre'}), (b:City {name: 'Lille'}) CREATE (a)-[:ROAD {distance_km: 230.0, speed_limit_kph: 110}]->(b);
MATCH (a:ChargingStation {id: 'CS1'}), (b:ChargingStation {id: 'CS2'}) CREATE (a)-[:ROAD {distance_km: 450.0, speed_limit_kph: 110}]->(b);
MATCH (a:ChargingStation {id: 'CS3'}), (b:ChargingStation {id: 'CS4'}) CREATE (a)-[:ROAD {distance_km: 600.0, speed_limit_kph: 120}]->(b);
MATCH (a:ChargingStation {id: 'CS5'}), (b:ChargingStation {id: 'CS6'}) CREATE (a)-[:ROAD {distance_km: 400.0, speed_limit_kph: 110}]->(b);
MATCH (a:ChargingStation {id: 'CS7'}), (b:ChargingStation {id: 'CS8'}) CREATE (a)-[:ROAD {distance_km: 500.0, speed_limit_kph: 110}]->(b);
MATCH (a:ChargingStation {id: 'CS9'}), (b:ChargingStation {id: 'CS10'}) CREATE (a)-[:ROAD {distance_km: 700.0, speed_limit_kph: 120}]->(b);

// create geo point
MATCH (x: ChargingStation|City)
SET x.geo = point({longitude:x.lon, latitude:x.lat}), x:Geo;
// create geo index
CREATE POINT INDEX point_index_geo
IF NOT EXISTS
FOR (n:Geo) ON (n.geo);

MATCH (cs:ChargingStation)
MERGE (cs)-[:CHARGE {station_id:cs.id, power_kw: cs.power_kw, time_in_minutes: 15}]->(cs)
MERGE (cs)-[:CHARGE {station_id:cs.id, power_kw: cs.power_kw, time_in_minutes: 30}]->(cs);

MATCH ()-[r:ROAD]-()
SET r.hourly_expected_speed_kph = 
  [h IN range(0,23) | r.speed_limit_kph];

// Lyon-->Marseille with rush hours
MATCH (x:Geo {name:"Lyon"})-[r {speed_limit_kph: 110}]-(y:Geo {name:"Marseille"})
SET r.hourly_expected_speed_kph =
  [80,80,80,80,80,110,110,110,
  110,110,110,110,110,110,110,110,
  110,80,80,80,80,80,80,80];
