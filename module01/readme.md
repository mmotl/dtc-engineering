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

## terraform
- install terraform via brew:  
  *(might require to update xcode dev tools)*
```zsh
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```
