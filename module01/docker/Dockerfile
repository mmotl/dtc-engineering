FROM python:3.9

RUN pip install pandas

#copies from a source file into a destination file in this container
WORKDIR /app
COPY pipeline.py pipeline.py 

# ENTRYPOINT [ "bash" ]
ENTRYPOINT [ "python", "pipeline.py" ]