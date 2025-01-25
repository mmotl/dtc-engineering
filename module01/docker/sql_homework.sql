SELECT *
FROM green_taxi_trips
LIMIT 5;

SELECT count(*)
FROM green_taxi_trips;

/*
## Question 3. Trip Segmentation Count

During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), how many trips, **respectively**, happened:
1. Up to 1 mile
2. In between 1 (exclusive) and 3 miles (inclusive),
3. In between 3 (exclusive) and 7 miles (inclusive),
4. In between 7 (exclusive) and 10 miles (inclusive),
5. Over 10 miles 

Answers:

- 104,802;  197,670;  110,612;  27,831;  35,281
- 104,802;  198,924;  109,603;  27,678;  35,189
- 104,793;  201,407;  110,612;  27,831;  35,281
- 104,793;  202,661;  109,603;  27,678;  35,189
- 104,838;  199,013;  109,645;  27,688;  35,202
*/

-- my query    
 SELECT
	CASE
	WHEN trip_distance <= 1 THEN 'a_1_mile'
    WHEN trip_distance > 1 AND trip_distance <= 3 THEN 'b_1_to_3_miles'
    WHEN trip_distance > 3 AND trip_distance <= 7 THEN 'c_3_to_7_miles'
    WHEN trip_distance > 7 AND trip_distance <= 10 THEN 'd_7_to_10_miles'
    WHEN trip_distance > 10 THEN 'e_trips_over_10_miles'
    END AS trips_cat,
    count(*) AS trips_count
FROM green_taxi_trips
WHERE CAST(lpep_pickup_datetime AS DATE) >= '2019-10-01'
  AND CAST(lpep_dropoff_datetime AS DATE) < '2019-11-01' 
GROUP BY trips_cat;

/*
a_1_mile	104830
b_1_to_3_miles	198995
c_3_to_7_miles	109642
d_7_to_10_miles	27686
e_trips_over_10_miles	35201
*/


-- Question 4. Longest trip for each day
-- Which was the pick up day with the longest trip distance?
-- Use the pick up time for your calculations.
-- Tip: For every day, we only care about one single trip with the longest distance.


SELECT lpep_pickup_datetime::date AS date 
			,MAX(trip_distance) AS distance
FROM green_taxi_trips
GROUP BY lpep_pickup_datetime::date
ORDER BY distance DESC;

-- 2019-10-31, 515,89 miles


-- ## Question 5. Three biggest pickup zones
-- Which were the top pickup locations with over 13,000 in
-- `total_amount` (across all trips) for 2019-10-18?


SELECT
			zpu."Zone"
			,sum(round(total_amount::numeric, 2)) AS max_value
FROM green_taxi_trips t 
		 LEFT JOIN zones zpu
		 		ON t."PULocationID" = zpu."LocationID"
WHERE lpep_pickup_datetime::DATE = '2019-10-18'
GROUP BY zpu."Zone"
ORDER BY max_value DESC;

SELECT *
FROM zones;

/*
18686.68	East Harlem North
16797.26	East Harlem South
13029.79	Morningside Heights
*/

-- ## Question 6. Largest tip
-- For the passengers picked up in October 2019 in the zone
-- named "East Harlem North" which was the drop off zone that had
-- the largest tip?

SELECT 
*
FROM green_taxi_trips t;

SELECT
  zdo."Zone" AS dropoff
	,round(MAX(tip_amount)::numeric,2) AS max_tip
FROM green_taxi_trips t
	LEFT JOIN zones zpu
		ON t."PULocationID" = zpu."LocationID"
	LEFT JOIN zones zdo
		ON t."DOLocationID" = zdo."LocationID"
WHERE zpu."Zone" = 'East Harlem North'
GROUP BY zdo."Zone"
ORDER BY max_tip DESC;


SELECT tpep_pickup_datetime
			,tpep_dropoff_datetime 
			,round(total_amount::numeric, 2)
			,concat(zpu."Borough", ' / ', zpu."Zone") AS pickup_loc
			,concat(zdo."Borough", ' / ', zdo."Zone") AS dropoff_loc
FROM green_taxi_trips t,
 		 zones zpu,
		 zones zdo
WHERE 
	t."PULocationID" = zpu."LocationID" AND 
	t."DOLocationID" = zdo."LocationID";

-- different code with join

SELECT tpep_pickup_datetime
			,tpep_dropoff_datetime 
			,round(total_amount::numeric, 2)
			,concat(zpu."Borough", ' / ', zpu."Zone") AS pickup_loc
			,concat(zdo."Borough", ' / ', zdo."Zone") AS dropoff_loc
FROM green_taxi_trips t
		 LEFT JOIN zones zpu
		 		ON t."PULocationID" = zpu."LocationID"
		 LEFT JOIN zones zdo
		 		ON t."DOLocationID" = zdo."LocationID";


SELECT tpep_pickup_datetime
			,tpep_dropoff_datetime 
			,round(total_amount::numeric, 2)
			,concat(zpu."Borough", ' / ', zpu."Zone") AS pickup_loc
			,concat(zdo."Borough", ' / ', zdo."Zone") AS dropoff_loc
FROM green_taxi_trips t

SELECT tpep
FROM green_taxi_trips;

GROUP BY 


