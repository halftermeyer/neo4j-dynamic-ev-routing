# 🗺️ Use Case: Electric-Vehicle Routing

The goal: Find a route from source to target that respects time and energy constraints, and minimizes energy use.

## Data

Copy and paste the full [ingestion script](EV_ingestion_script.cypher) in Query to load a test dataset.

## Data Model

We've just loaded a graph where `(:Geo)` nodes represent intersections, cities, or charging stations.
Some (:Geo) nodes are also labeled `(:ChargingStation)`.
Connections include:
* `:ROAD` relationships between :Geo nodes, with properties like distance_km, speed_limit_kph, and hourly_expected_speed_kph (a list of 24 hourly expected mean speed assuming a 24-hour wrap-around for simplicity)
* `:CHARGE` self-loops on :ChargingStation nodes, with power_kw and time_in_minutes. In the examples dataset, a charging station has two loops L15 and L30 of 15 and 30 minutes. To charge 75 minutes at station `cs`, you need to match `(cs:ChargingStation)-[L30]->(cs)-[L30]->(cs)-[L15]->(cs)`
* A `(:Car)` node with `battery_capacity_kwh`, `efficiency_kwh_per_km`, and `current_soc_percent`.

<img width="800" height="610" alt="1_Z80JDMU2eE3qRbCoRc0pxQ" src="https://github.com/user-attachments/assets/c5fb9c39-7278-4efc-bfc8-c7c3b1b2780a" />

## Parameters

``` cypher
:params {
  max_mins: 10000,
  car_id: "Car6",
  source_geo_name: "Nice",
  target_geo_name: "Le Havre",
  detour_ratio: 1.2,
  min_soc: 1,
  max_soc: 100,
  departure_datetime: datetime("2025-10-15T17:46:16.114000000Z")
  }
```

<img width="800" height="482" alt="1_ZGxcQExHjngnRoUQOUwl0g" src="https://github.com/user-attachments/assets/15979fc8-ca09-4bde-b034-a58d9167feb7" />

### Query

```cypher
// MATCH A QUANTIFIED PATH PATTERN

// Specify Cypher version and runtime
CYPHER 25 runtime=parallel
MATCH (c:Car {id: $car_id})
// Define the path with repeatable elements
MATCH REPEATABLE ELEMENTS p = (a:Geo {name: $source_geo_name})
  (() -[rels:ROAD|CHARGE]- (x:Geo
     // Spatial pruning to avoid excessive detours
     WHERE point.distance(x.geo, b.geo) < $detour_ratio * point.distance(a.geo, b.geo)
     AND point.distance(x.geo, a.geo) < $detour_ratio * point.distance(a.geo, b.geo)
  )){1,1000}
  (b:Geo {name: $target_geo_name})

// COMPUTE CURRENT STATE AND PRUNE

// Apply stateful pruning with allReduce
WHERE allReduce(
  // initial state
  current = {soc: c.current_soc_percent, time_in_min: 0.0},  // Initialize state
  r IN rels |  // Accumulate per relationship at traversal time
    CASE
      WHEN r:ROAD
        // state of charge goes down, time runs (according to expected speed)
        THEN {soc: current.soc - (r.distance_km*c.efficiency_kwh_per_km*100) / c.battery_capacity_kwh,
            time_in_min: current.time_in_min
                        + 60.0 *(r.distance_km / r.hourly_expected_speed_kph[
                ($departure_datetime+duration({minutes:current.time_in_min})).hour
                                  ]) }

      WHEN r:CHARGE
        // state of charge goes up, time runs
        THEN {soc: current.soc + (r.power_kw*(r.time_in_minutes/60.0)*100) / c.battery_capacity_kwh,
            time_in_min: current.time_in_min + r.time_in_minutes }
    END,
  // Prune if constraints are violated
  $min_soc <= current.soc <= $max_soc
    AND current.time_in_min <= $max_mins
  )
// Return for next stage
RETURN c, p

// SCORE, ORDER AND SELECT

NEXT

// Score and order paths
RETURN c, p, reduce(current = {soc: c.current_soc_percent, time_in_min: 0.0, energy_kwh: 0.0},
  r IN relationships(p) | CASE
    WHEN r:ROAD
      THEN {soc: current.soc - (r.distance_km*c.efficiency_kwh_per_km*100) / c.battery_capacity_kwh,
          time_in_min: current.time_in_min
                        + 60.0 *(r.distance_km / r.hourly_expected_speed_kph[
                ($departure_datetime+duration({minutes:current.time_in_min})).hour
                                  ]),
          energy_kwh: current.energy_kwh + (r.distance_km * c.efficiency_kwh_per_km)}
    WHEN r:CHARGE
      THEN {soc: current.soc + (r.power_kw*(r.time_in_minutes/60.0)*100) / c.battery_capacity_kwh,
          time_in_min: current.time_in_min + r.time_in_minutes,
          energy_kwh: current.energy_kwh}
  END) AS final_values

ORDER BY final_values.time_in_min ASC,
         final_values.energy_kwh ASC,
         size(relationships(p)) ASC
LIMIT 1

```

<img width="800" height="594" alt="1_IkUUMyOH6cHZoCDA5Bvx2w" src="https://github.com/user-attachments/assets/6e52cc80-d167-4bb9-badc-41be00323a99" />

