# ----------------------------------------------------------------------------------------

curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "file-source",
    "config": {
      "connector.class": "FileStreamSource",
      "tasks.max": "1",
      "file": "/input/input.txt",
      "topic": "file-topic"
    }
  }'


# ----------------------------------------------------------------------------------------

docker ps

# To check container id of your kafka container

# ----------------------------------------------------------------------------------------

docker exec -it <CONTAINER_ID> bash

# ----------------------------------------------------------------------------------------

kafka-console-consumer --bootstrap-server localhost:9092 --topic file-topic --from-beginning

# ----------------------------------------------------------------------------------------
