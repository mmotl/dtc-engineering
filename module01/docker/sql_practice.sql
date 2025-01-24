SELECT *
FROM yellow_taxi_trips
LIMIT 5;

SELECT *
FROM zones;

ALTER TABLE yellow_taxi_data 
RENAME TO yellow_taxi_trips;

-- "DOLocationID"
-- "PULocationID"
-- "LocationID"

SELECT tpep_pickup_datetime
			,tpep_dropoff_datetime 
			,round(total_amount::numeric, 2)
			,concat(zpu."Borough", ' / ', zpu."Zone") AS pickup_loc
			,concat(zdo."Borough", ' / ', zdo."Zone") AS dropoff_loc
FROM yellow_taxi_trips t,
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
FROM yellow_taxi_trips t
		 LEFT JOIN zones zpu
		 		ON t."PULocationID" = zpu."LocationID"
		 LEFT JOIN zones zdo
		 		ON t."DOLocationID" = zdo."LocationID";


SELECT tpep_pickup_datetime
			,tpep_dropoff_datetime 
			,round(total_amount::numeric, 2)
			,concat(zpu."Borough", ' / ', zpu."Zone") AS pickup_loc
			,concat(zdo."Borough", ' / ', zdo."Zone") AS dropoff_loc
FROM yellow_taxi_trips t

SELECT tpep
FROM yellow_taxi_trips;

GROUP BY 


