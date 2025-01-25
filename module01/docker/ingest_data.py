
import pandas as pd
import sqlalchemy
from dotenv import dotenv_values, load_dotenv


def get_sql_config():
    '''
        Function loads credentials from .env file and
        returns a dictionary containing the data needed for sqlalchemy.create_engine()
    '''
    needed_keys = ['host', 'port', 'database','user', 'password']
    dotenv_dict = dotenv_values(".env")
    sql_config = {key:dotenv_dict[key] for key in needed_keys if key in dotenv_dict}
    return sql_config

def get_engine():
    sql_config = get_sql_config()
    engine = sqlalchemy.create_engine('postgresql://user:pass@host/database',
                        connect_args=sql_config
                        )
    return engine  


# df = pd.read_csv('data/yellow_tripdata_2021-01.csv')
df = pd.read_csv('data/green_tripdata_2019-10.csv')
print('dataframe read')

engine = get_engine()
print('engine created')

# df_iter = pd.read_csv('data/yellow_tripdata_2021-01.csv', iterator=True, chunksize=100000)
df_iter = pd.read_csv('data/green_tripdata_2019-10.csv', iterator=True, chunksize=100000, low_memory=False)
# df_iter = pd.read_csv('data/yellow_head.csv', iterator=True, chunksize=400)
print('iterator created')

df.head(0).to_sql(name='green_taxi_trips', con=engine, if_exists='replace')
print('head of table created')

while True:
    try:
        df = next(df_iter)

        # for yellow
        # df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
        # df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

        # for green 
        df.lpep_pickup_datetime = pd.to_datetime(df.lpep_pickup_datetime)
        df.lpep_dropoff_datetime = pd.to_datetime(df.lpep_dropoff_datetime)

        # df.to_sql(name='yellow_taxi_trips', con=engine, if_exists='append')
        df.to_sql(name='green_taxi_trips', con=engine, if_exists='append')

        print('inserted another chunk')
    except StopIteration:
        print('finished inserting')
        break