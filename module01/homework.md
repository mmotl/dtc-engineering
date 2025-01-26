# Module 1 Homework: Docker & SQL & Terraform

This is the solution file for Matthias Motl taking part in the 2025 data engineering zoomcamp  
It contains the SQL code and the command line commands for solving the homework. 

## Question 1. Understanding docker first run 

Run docker with the `python:3.12.8` image in an interactive mode, use the entrypoint `bash`.  

### CLI command
```zsh
docker run -it --entrypoint=bash python:3.12.8
pip --version
```
What's the version of `pip` in the image?
### Solution
- pip 24.3.1

## Question 2. Understanding Docker networking and docker-compose

Given the following `docker-compose.yaml`, what is the `hostname` and `port` that **pgadmin** should use to connect to the postgres database?

```yaml
services:
  db:
    container_name: postgres
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: 'postgres'
      POSTGRES_PASSWORD: 'postgres'
      POSTGRES_DB: 'ny_taxi'
    ports:
      - '5433:5432'
    volumes:
      - vol-pgdata:/var/lib/postgresql/data

  pgadmin:
    container_name: pgadmin
    image: dpage/pgadmin4:latest
    environment:
      PGADMIN_DEFAULT_EMAIL: "pgadmin@pgadmin.com"
      PGADMIN_DEFAULT_PASSWORD: "pgadmin"
    ports:
      - "8080:80"
    volumes:
      - vol-pgadmin_data:/var/lib/pgadmin  

volumes:
  vol-pgdata:
    name: vol-pgdata
  vol-pgadmin_data:
    name: vol-pgadmin_data
```
### Solution
- db:5432

<!--
##  Prepare Postgres

Run Postgres and load data as shown in the videos
We'll use the green taxi trips from October 2019:

```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz
```

You will also need the dataset with zones:

```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv
```

Download this data and put it into Postgres.

You can use the code from the course. It's up to you whether
you want to use Jupyter or a python script.
-->

## Question 3. Trip Segmentation Count

During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), how many trips, **respectively**, happened:
1. Up to 1 mile
2. In between 1 (exclusive) and 3 miles (inclusive),
3. In between 3 (exclusive) and 7 miles (inclusive),
4. In between 7 (exclusive) and 10 miles (inclusive),
5. Over 10 miles 

### Code
```SQL
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
```
### Solution
- 104,802;  198,924;  109,603;  27,678;  35,189

## Question 4. Longest trip for each day

Which was the pick up day with the longest trip distance?
Use the pick up time for your calculations.

### Code
```SQL
SELECT lpep_pickup_datetime::date AS date 
			,MAX(trip_distance) AS distance
FROM green_taxi_trips
GROUP BY lpep_pickup_datetime::date
ORDER BY distance DESC;
```
### Solution
- 2019-10-31


## Question 5. Three biggest pickup zones

Which were the top pickup locations with over 13,000 in
`total_amount` (across all trips) for 2019-10-18?

Consider only `lpep_pickup_datetime` when filtering by date.

### Code
```SQL
WITH max_totals AS (
    SELECT
        zpu."Zone",
        SUM(ROUND(total_amount::numeric, 2)) AS max_value
    FROM green_taxi_trips t
    LEFT JOIN zones zpu
        ON t."PULocationID" = zpu."LocationID"
    WHERE lpep_pickup_datetime::DATE = '2019-10-18'
    GROUP BY zpu."Zone"
)
SELECT *
FROM max_totals
WHERE max_value > 13000
ORDER BY max_value DESC;
```
### Solution
- East Harlem North, East Harlem South, Morningside Heights

## Question 6. Largest tip

For the passengers picked up in October 2019 in the zone
named "East Harlem North" which was the drop off zone that had
the largest tip?  
Note: it's `tip` , not `trip`  
We need the name of the zone, not the ID.  

### Code
```SQL
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
```
### Solution
- JFK Airport

## Question 7. Terraform Workflow

Which of the following sequences, **respectively**, describes the workflow for: 
1. Downloading the provider plugins and setting up backend,
2. Generating proposed changes and auto-executing the plan
3. Remove all resources managed by terraform`

### Solution
- terraform init, terraform apply -auto-approve, terraform destroy
> (in terraform apply, the "-auto-approve" flag allows us to run the generating without the need approve / to type "yes")

<!--
## Submitting the solutions

* Form for submitting: https://courses.datatalks.club/de-zoomcamp-2025/homework/hw1
-->