FROM python:3.12-alpine

RUN adduser -D -u 10001 connector
WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt
COPY code/ /app/code/
USER connector
ENTRYPOINT ["python", "/app/code/server.py"]
