FROM python:3.9

RUN pip install pandas sqlalchemy python-dotenv psycopg2-binary

#copies from a source file into a destination file in this container
WORKDIR /app
COPY pipeline.py pipeline.py 
# COPY ingest_data.py ingest_data.py  
# COPY data/yellow_tripdata_2021-01.csv /app/data/
# COPY data/yellow_head.csv /app/data/

# ENTRYPOINT [ "bash" ]
ENTRYPOINT [ "python", "pipeline.py" ]
# ENTRYPOINT [ "python", "ingest_data.py" ]