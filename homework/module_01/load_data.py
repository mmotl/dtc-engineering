import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
import os

# Database connection parameters
db_host = 'db'  # Docker service name
db_port = 5432  # Internal Docker port
db_name = 'ny_taxi'
db_user = 'postgres'
db_password = 'postgres'

# First, connect to the default postgres database to create ny_taxi if it doesn't exist
conn = psycopg2.connect(
    host=db_host,
    port=db_port,
    database='postgres',
    user=db_user,
    password=db_password
)
conn.autocommit = True
cur = conn.cursor()

# Create database if it doesn't exist
try:
    cur.execute(f"CREATE DATABASE {db_name};")
    print(f"Created database {db_name}")
except psycopg2.Error as e:
    print(f"Database {db_name} already exists or error: {e}")

cur.close()
conn.close()

# Now connect to the ny_taxi database
conn = psycopg2.connect(
    host=db_host,
    port=db_port,
    database=db_name,
    user=db_user,
    password=db_password
)
cur = conn.cursor()

# Load taxi_zone_lookup.csv
print("Loading taxi zones...")
zones_df = pd.read_csv('taxi_zone_lookup.csv')

# Create zones table
cur.execute("""
    DROP TABLE IF EXISTS zones CASCADE;
    CREATE TABLE zones (
        LocationID INTEGER PRIMARY KEY,
        Borough VARCHAR(50),
        Zone VARCHAR(100),
        service_zone VARCHAR(50)
    );
""")

# Insert zones data
for idx, row in zones_df.iterrows():
    cur.execute("""
        INSERT INTO zones (LocationID, Borough, Zone, service_zone) 
        VALUES (%s, %s, %s, %s)
    """, (row['LocationID'], row['Borough'], row['Zone'], row['service_zone']))

conn.commit()
print(f"Loaded {len(zones_df)} zones")

# Load green_tripdata_2025-11.parquet
print("Loading green taxi trips...")
trips_df = pd.read_parquet('green_tripdata_2025-11.parquet')

# Display columns to understand the schema
print("\nTrip data columns:")
print(trips_df.columns.tolist())
print("\nTrip data info:")
print(trips_df.info())
print(f"\nTotal rows: {len(trips_df)}")

# Create trips table
cur.execute("""
    DROP TABLE IF EXISTS green_trips CASCADE;
    CREATE TABLE green_trips (
        VendorID INTEGER,
        lpep_pickup_datetime TIMESTAMP,
        lpep_dropoff_datetime TIMESTAMP,
        store_and_fwd_flag VARCHAR(1),
        RatecodeID INTEGER,
        PULocationID INTEGER,
        DOLocationID INTEGER,
        passenger_count INTEGER,
        trip_distance NUMERIC,
        fare_amount NUMERIC,
        extra NUMERIC,
        mta_tax NUMERIC,
        tip_amount NUMERIC,
        tolls_amount NUMERIC,
        ehail_fee NUMERIC,
        total_amount NUMERIC,
        payment_type INTEGER,
        trip_type INTEGER,
        congestion_surcharge NUMERIC
    );
""")

# Prepare data for insertion
records = []
for idx, row in trips_df.iterrows():
    records.append((
        int(row['VendorID']) if pd.notna(row['VendorID']) else None,
        row['lpep_pickup_datetime'],
        row['lpep_dropoff_datetime'],
        row['store_and_fwd_flag'] if pd.notna(row['store_and_fwd_flag']) else None,
        int(row['RatecodeID']) if pd.notna(row['RatecodeID']) else None,
        int(row['PULocationID']) if pd.notna(row['PULocationID']) else None,
        int(row['DOLocationID']) if pd.notna(row['DOLocationID']) else None,
        int(row['passenger_count']) if pd.notna(row['passenger_count']) else None,
        float(row['trip_distance']) if pd.notna(row['trip_distance']) else None,
        float(row['fare_amount']) if pd.notna(row['fare_amount']) else None,
        float(row['extra']) if pd.notna(row['extra']) else None,
        float(row['mta_tax']) if pd.notna(row['mta_tax']) else None,
        float(row['tip_amount']) if pd.notna(row['tip_amount']) else None,
        float(row['tolls_amount']) if pd.notna(row['tolls_amount']) else None,
        float(row['ehail_fee']) if pd.notna(row['ehail_fee']) else None,
        float(row['total_amount']) if pd.notna(row['total_amount']) else None,
        int(row['payment_type']) if pd.notna(row['payment_type']) else None,
        int(row['trip_type']) if pd.notna(row['trip_type']) else None,
        float(row['congestion_surcharge']) if pd.notna(row['congestion_surcharge']) else None,
    ))

# Batch insert
batch_size = 1000
for i in range(0, len(records), batch_size):
    batch = records[i:i+batch_size]
    cur.executemany("""
        INSERT INTO green_trips VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, batch)
    conn.commit()
    print(f"Inserted {min(i+batch_size, len(records))}/{len(records)} trips")

print("\nData loading complete!")
cur.close()
conn.close()
