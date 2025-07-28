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

docker exec -it kafka bash

# ----------------------------------------------------------------------------------------

kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic file-topic --from-beginning
