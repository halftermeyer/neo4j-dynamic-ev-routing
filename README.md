# neo4j-dynamic-ev-routing
## Dynamic Electric Vehicle Routing with Neo4j
This document outlines a use case for dynamic routing of electric vehicles (EVs) using Neo4j’s Cypher 25 query language. The scenario involves finding an optimal route for an electrical vehical (for instance, Car5: 56 kWh battery, 0.19 kWh/km efficiency, 39% initial state of charge from CityA to CityB), considering battery constraints, charging stops, and a maximum travel time of 300 minutes. A detour ratio (d = 1.5) ensures nodes in the path are within 1.5 times the direct distance from CityA to CityB, preventing excessive detours. This approach leverages Neo4j’s graph capabilities to model roads, charging stations, and stateful path computations, ideal for prototyping or integrating with tools like OpenStreetMap.
## Graph Model
The graph represents a road network around the New York area, with nodes and relationships:

### Nodes:
- `:City` Start/end points (e.g., CityA, CityB).
- `:ChargingStation`` Charging points with power_kw (e.g., CS3 at 350 kW).
- `:OP` Operational waypoints.
- `:POI` Points of interest (e.g., museums, monuments).
- `:Car` Vehicles with `battery_capacity_kwh`, `efficiency_kwh_per_km`, and `current_soc_percent`.
All nodes with a geo property (point({longitude: lon, latitude: lat})) are labeled `:Geo` for spatial queries. A point index is set.


### Relationships:
- `:ROAD` Semantically undirected, with `distance_km` and `speed_limit_kph`.
- `:CHARGE` Self-loops on `:ChargingStation` for charging sessions (1, 2, 5, 10, 30, 60, 120 minutes).



## Setup Queries
The following Cypher queries set up the graph, add spatial properties, and create a spatial index.

1. Create Dataset
Creates nodes and `:ROAD` relationships for the network, including Car5.
```cypher
CREATE (n:ChargingStation {lat: 40.6394, lon: -73.975, id: 'CS1', power_kw: 350});
CREATE (n:City {lat: 40.275, lon: -73.7768, name: 'CityA'});
CREATE (n:OP {lat: 40.7365, lon: -73.3233, id: 'OP1'});
CREATE (n:ChargingStation {lat: 40.8922, lon: -73.9131, id: 'CS2', power_kw: 100});
CREATE (n:OP {lat: 40.4219, lon: -73.9702, id: 'OP2'});
CREATE (n:ChargingStation {lat: 40.2186, lon: -73.4946, id: 'CS3', power_kw: 350});
CREATE (n:OP {lat: 40.0265, lon: -73.8012, id: 'OP3'});
CREATE (n:OP {lat: 40.6499, lon: -73.4551, id: 'OP4'});
CREATE (n:POI {lat: 40.2204, lon: -73.4107, name: 'POI1', type: 'Museum'});
CREATE (n:OP {lat: 40.8094, lon: -73.9935, id: 'OP5'});
CREATE (n:POI {lat: 40.8058, lon: -73.3019, name: 'POI2', type: 'Museum'});
CREATE (n:POI {lat: 40.3403, lon: -73.8445, name: 'POI3', type: 'Monument'});
CREATE (n:OP {lat: 40.9572, lon: -73.6634, id: 'OP6'});
CREATE (n:POI {lat: 40.0927, lon: -73.9033, name: 'POI4', type: 'Monument'});
CREATE (n:OP {lat: 40.8475, lon: -73.3963, id: 'OP7'});
CREATE (n:OP {lat: 40.8071, lon: -73.2703, id: 'OP8'});
CREATE (n:ChargingStation {lat: 40.5362, lon: -73.0269, id: 'CS4', power_kw: 150});
CREATE (n:POI {lat: 40.3785, lon: -73.448, name: 'POI5', type: 'Museum'});
CREATE (n:City {lat: 40.8294, lon: -73.3815, name: 'CityB'});
CREATE (n:City {lat: 40.8617, lon: -73.4226, name: 'CityC'});
CREATE (c:Car {id: 'Car1', battery_capacity_kwh: 57, efficiency_kwh_per_km: 0.16, current_soc_percent: 30});
CREATE (c:Car {id: 'Car2', battery_capacity_kwh: 79, efficiency_kwh_per_km: 0.15, current_soc_percent: 66});
CREATE (c:Car {id: 'Car3', battery_capacity_kwh: 96, efficiency_kwh_per_km: 0.16, current_soc_percent: 52});
CREATE (c:Car {id: 'Car4', battery_capacity_kwh: 98, efficiency_kwh_per_km: 0.16, current_soc_percent: 78});
CREATE (c:Car {id: 'Car5', battery_capacity_kwh: 56, efficiency_kwh_per_km: 0.19, current_soc_percent: 39});
MATCH (a:ChargingStation {id: 'CS1'}), (b:ChargingStation {id: 'CS2'}) CREATE (a)-[:ROAD {distance_km: 90.11, speed_limit_kph: 100}]->(b);
MATCH (a:ChargingStation {id: 'CS1'}), (b:OP {id: 'OP2'}) CREATE (a)-[:ROAD {distance_km: 75.34, speed_limit_kph: 50}]->(b);
MATCH (a:ChargingStation {id: 'CS1'}), (b:OP {id: 'OP5'}) CREATE (a)-[:ROAD {distance_km: 59.22, speed_limit_kph: 80}]->(b);
MATCH (a:City {name: 'CityA'}), (b:OP {id: 'OP2'}) CREATE (a)-[:ROAD {distance_km: 84.1, speed_limit_kph: 50}]->(b);
MATCH (a:City {name: 'CityA'}), (b:ChargingStation {id: 'CS3'}) CREATE (a)-[:ROAD {distance_km: 99.63, speed_limit_kph: 100}]->(b);
MATCH (a:City {name: 'CityA'}), (b:OP {id: 'OP3'}) CREATE (a)-[:ROAD {distance_km: 86.46, speed_limit_kph: 110}]->(b);
MATCH (a:City {name: 'CityA'}), (b:POI {name: 'POI3'}) CREATE (a)-[:ROAD {distance_km: 32.56, speed_limit_kph: 90}]->(b);
MATCH (a:City {name: 'CityA'}), (b:POI {name: 'POI4'}) CREATE (a)-[:ROAD {distance_km: 76.83, speed_limit_kph: 60}]->(b);
MATCH (a:OP {id: 'OP1'}), (b:OP {id: 'OP4'}) CREATE (a)-[:ROAD {distance_km: 54.59, speed_limit_kph: 80}]->(b);
MATCH (a:OP {id: 'OP1'}), (b:POI {name: 'POI2'}) CREATE (a)-[:ROAD {distance_km: 25.14, speed_limit_kph: 100}]->(b);
MATCH (a:OP {id: 'OP1'}), (b:OP {id: 'OP7'}) CREATE (a)-[:ROAD {distance_km: 46.01, speed_limit_kph: 80}]->(b);
MATCH (a:OP {id: 'OP1'}), (b:OP {id: 'OP8'}) CREATE (a)-[:ROAD {distance_km: 30.59, speed_limit_kph: 120}]->(b);
MATCH (a:OP {id: 'OP1'}), (b:City {name: 'CityB'}) CREATE (a)-[:ROAD {distance_km: 37.97, speed_limit_kph: 110}]->(b);
MATCH (a:OP {id: 'OP1'}), (b:City {name: 'CityC'}) CREATE (a)-[:ROAD {distance_km: 55.35, speed_limit_kph: 120}]->(b);
MATCH (a:ChargingStation {id: 'CS2'}), (b:OP {id: 'OP5'}) CREATE (a)-[:ROAD {distance_km: 39.96, speed_limit_kph: 70}]->(b);
MATCH (a:ChargingStation {id: 'CS2'}), (b:OP {id: 'OP6'}) CREATE (a)-[:ROAD {distance_km: 89.33, speed_limit_kph: 90}]->(b);
MATCH (a:OP {id: 'OP2'}), (b:POI {name: 'POI3'}) CREATE (a)-[:ROAD {distance_km: 51.9, speed_limit_kph: 70}]->(b);
MATCH (a:ChargingStation {id: 'CS3'}), (b:POI {name: 'POI1'}) CREATE (a)-[:ROAD {distance_km: 29.06, speed_limit_kph: 80}]->(b);
MATCH (a:ChargingStation {id: 'CS3'}), (b:POI {name: 'POI5'}) CREATE (a)-[:ROAD {distance_km: 57.68, speed_limit_kph: 90}]->(b);
MATCH (a:OP {id: 'OP3'}), (b:POI {name: 'POI4'}) CREATE (a)-[:ROAD {distance_km: 42.14, speed_limit_kph: 110}]->(b);
MATCH (a:OP {id: 'OP4'}), (b:POI {name: 'POI2'}) CREATE (a)-[:ROAD {distance_km: 75.7, speed_limit_kph: 110}]->(b);
MATCH (a:OP {id: 'OP4'}), (b:OP {id: 'OP7'}) CREATE (a)-[:ROAD {distance_km: 71.39, speed_limit_kph: 100}]->(b);
MATCH (a:OP {id: 'OP4'}), (b:OP {id: 'OP8'}) CREATE (a)-[:ROAD {distance_km: 84.02, speed_limit_kph: 80}]->(b);
MATCH (a:OP {id: 'OP4'}), (b:POI {name: 'POI5'}) CREATE (a)-[:ROAD {distance_km: 93.99, speed_limit_kph: 70}]->(b);
MATCH (a:OP {id: 'OP4'}), (b:City {name: 'CityB'}) CREATE (a)-[:ROAD {distance_km: 67.18, speed_limit_kph: 120}]->(b);
MATCH (a:OP {id: 'OP4'}), (b:City {name: 'CityC'}) CREATE (a)-[:ROAD {distance_km: 74.2, speed_limit_kph: 60}]->(b);
MATCH (a:POI {name: 'POI1'}), (b:POI {name: 'POI5'}) CREATE (a)-[:ROAD {distance_km: 56.24, speed_limit_kph: 50}]->(b);
MATCH (a:POI {name: 'POI2'}), (b:OP {id: 'OP7'}) CREATE (a)-[:ROAD {distance_km: 35.74, speed_limit_kph: 60}]->(b);
MATCH (a:POI {name: 'POI2'}), (b:OP {id: 'OP8'}) CREATE (a)-[:ROAD {distance_km: 10.95, speed_limit_kph: 70}]->(b);
MATCH (a:POI {name: 'POI2'}), (b:City {name: 'CityB'}) CREATE (a)-[:ROAD {distance_km: 28.75, speed_limit_kph: 70}]->(b);
MATCH (a:POI {name: 'POI2'}), (b:City {name: 'CityC'}) CREATE (a)-[:ROAD {distance_km: 46.09, speed_limit_kph: 110}]->(b);
MATCH (a:POI {name: 'POI3'}), (b:POI {name: 'POI4'}) CREATE (a)-[:ROAD {distance_km: 88.09, speed_limit_kph: 60}]->(b);
MATCH (a:OP {id: 'OP6'}), (b:OP {id: 'OP7'}) CREATE (a)-[:ROAD {distance_km: 100.0, speed_limit_kph: 110}]->(b);
MATCH (a:OP {id: 'OP6'}), (b:City {name: 'CityC'}) CREATE (a)-[:ROAD {distance_km: 89.69, speed_limit_kph: 110}]->(b);
MATCH (a:OP {id: 'OP7'}), (b:OP {id: 'OP8'}) CREATE (a)-[:ROAD {distance_km: 45.82, speed_limit_kph: 120}]->(b);
MATCH (a:OP {id: 'OP7'}), (b:City {name: 'CityB'}) CREATE (a)-[:ROAD {distance_km: 8.09, speed_limit_kph: 90}]->(b);
MATCH (a:OP {id: 'OP7'}), (b:City {name: 'CityC'}) CREATE (a)-[:ROAD {distance_km: 10.37, speed_limit_kph: 50}]->(b);
MATCH (a:OP {id: 'OP8'}), (b:City {name: 'CityB'}) CREATE (a)-[:ROAD {distance_km: 39.28, speed_limit_kph: 60}]->(b);
MATCH (a:OP {id: 'OP8'}), (b:City {name: 'CityC'}) CREATE (a)-[:ROAD {distance_km: 56.05, speed_limit_kph: 90}]->(b);
MATCH (a:City {name: 'CityB'}), (b:City {name: 'CityC'}) CREATE (a)-[:ROAD {distance_km: 18.12, speed_limit_kph: 100}]->(b);
```
2. Set Names
Sets the name property from id for nodes with an id (e.g., ChargingStations, OPs). All `:Geo` nodes have a name now.
```cypher
MATCH (x:Geo WHERE NOT x.id IS null)
SET x.name=x.id
```
3. Create geo points
Adds the :Geo label and geo property for spatial queries.
```cypher
MATCH (x: ChargingStation|City|OP|POI)
SET x.geo = point({longitude:x.lon, latitude:x.lat}), x:Geo
```
4. Create Geo Index
Optimizes spatial queries with a point index.
```cypher
CREATE POINT INDEX point_index_geo FOR (n:Geo) ON (n.geo)
```
5. Charging Loops
Creates `:CHARGE` self-loops on `:ChargingStation` nodes for various durations. To charge 42 minutes, you will need to traverse `(cs)-[:CHARGE {station_id:cs.id, power_kw: cs.power_kw, time_in_minutes: 30}]-(cs)-[:CHARGE {station_id:cs.id, power_kw: cs.power_kw, time_in_minutes: 10}]-(cs)-[:CHARGE {station_id:cs.id, power_kw: cs.power_kw, time_in_minutes: 2}]-(cs)`
```cypher
MATCH (cs:ChargingStation)
MERGE (cs)-[:CHARGE {station_id:cs.id, power_kw: cs.power_kw, time_in_minutes: 1}]->(cs)
MERGE (cs)-[:CHARGE {station_id:cs.id, power_kw: cs.power_kw, time_in_minutes: 2}]->(cs)
MERGE (cs)-[:CHARGE {station_id:cs.id, power_kw: cs.power_kw, time_in_minutes: 5}]->(cs)
MERGE (cs)-[:CHARGE {station_id:cs.id, power_kw: cs.power_kw, time_in_minutes: 10}]->(cs)
MERGE (cs)-[:CHARGE {station_id:cs.id, power_kw: cs.power_kw, time_in_minutes: 30}]->(cs)
MERGE (cs)-[:CHARGE {station_id:cs.id, power_kw: cs.power_kw, time_in_minutes: 60}]->(cs)
MERGE (cs)-[:CHARGE {station_id:cs.id, power_kw: cs.power_kw, time_in_minutes: 120}]->(cs)
```
6. Set Parameters
Defines parameters for the target query.
```cypher
:params {
  max_mins: 300,
  car_id: "Car5",
  source_geo_name: "CityA",
  target_geo_name: "CityB",
  detour_ratio: 1.5,
  min_soc: 0,
  max_soc: 100
}
```

## Path-Finding Query
The target query finds the fastest path for Car5 from CityA to CityB, ensuring:

- State of Charge (soc) stays between $min_soc and max_soc.
- Total time is under $max_mins minutes.
- Each visited nodes `x` satisfies the detour ratio: `dist(x, b) < 1.5 * dist(a, b)`.

```cypher
CYPHER 25
// route from source to target with car
// max_mins is the maximum allowed time in minutes
// detour_ratio defines how much further that the source you're allowed to be from the target

MATCH (c:Car {id: $car_id})
MATCH REPEATABLE ELEMENTS p = (a:Geo {name: $source_geo_name})(()-[rels:ROAD|CHARGE]-(x:Geo
  WHERE point.distance(x.geo, b.geo) < $detour_ratio * point.distance(a.geo, b.geo)
)){1,10}(b:Geo {name: $target_geo_name})
WHERE allReduce(
  current = {soc: c.current_soc_percent, time_in_min: 0.0},
  r IN rels |
    CASE
      WHEN r:ROAD
        // state of charge goes down
        THEN {soc: current.soc - (r.distance_km*c.efficiency_kwh_per_km*100) / c.battery_capacity_kwh,
            time_in_min: current.time_in_min + 60.0*(r.distance_km / r.speed_limit_kph)}
      
      WHEN r:CHARGE
        // state of charge goes up
        THEN {soc: current.soc + (r.power_kw*(r.time_in_minutes/60.0)*100) / c.battery_capacity_kwh,
            time_in_min: current.time_in_min + r.time_in_minutes}

    END,
  $min_soc <= current.soc <= $max_soc AND current.time_in_min <= $max_mins
)
WITH p, c, reduce(current = {soc: c.current_soc_percent, time_in_min: 0.0},
  r IN rels | CASE
    WHEN r:ROAD
      THEN {soc: current.soc - (r.distance_km*c.efficiency_kwh_per_km*100) / c.battery_capacity_kwh,
          time_in_min: current.time_in_min + 60.0*(r.distance_km / r.speed_limit_kph)}
    WHEN r:CHARGE
      THEN {soc: current.soc + (r.power_kw*(r.time_in_minutes/60.0)*100) / c.battery_capacity_kwh,
          time_in_min: current.time_in_min + r.time_in_minutes}
  END) AS final_values
RETURN c, p, final_values ORDER BY final_values.time_in_min ASC LIMIT 1
```

