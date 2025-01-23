## docker
```zsh
  docker run -it --entrypoint=bash python:3.9
```
gives us a docker container starting with bash prompt running python 3.9
- to enter python prompt, type 'python'
- to exit python prompt, press 'control-D'
- to exit container, type 'exit'

 creating a Dockerimage to be able to permanently install packages:
```Dockerfile
FROM python:3.9
RUN pip install pandas
ENTRYPOINT [ "bash" ]
```
to build an image from the dockerfile, run:
```zsh
docker build -t test:pandas .
```
it will search for a *Dockerfile* in this directory.

to run the built image, run:
```zsh
docker run -it test:pandas
```

## postgres in docker 

```zsh
docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:13
```

## terraform
- install terraform via brew:  
  *(might require to update xcode dev tools)*
```zsh
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

## pgAdmnin/docker

```zsh
docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -p 8080:80 \
  dpage/pgadmin4
  ```

  ## postgres and pgadmin in docker network

```zsh
docker network create pg-network
```

```zsh
docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  --network=pg-network \
  --name pg-database \
  postgres:13
  ```

```zsh
  docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -p 8080:80 \
  --network=pg-network \
  --name pgadmin \
  dpage/pgadmin4
```

```zsh
docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -p 8090:90 \
  dbeaver/cloudbeaver
  --network=pg-network \
  --name dbeaver \
```

## docker compose

The YAML runs the two images.  
By being spun up via docker-compose, they're in a network, so this does not need to be specified.

this command executes the docker compose yml
```zsh
docker-compose up
```