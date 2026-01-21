# dtc-engineering

```zsh 
docker ps -a
```

```zsh 
docker ps -aq
````

```zsh 
docker rm `docker ps -aq`
````

```zsh
docker run --entrypoint=bash -it python:3.13.11-slim
```

```zsh
docker run -it --entrypoint=bash -v $(pwd)/test:/app/test python:3.13.11-slim
```