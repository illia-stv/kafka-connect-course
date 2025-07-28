curl http://localhost:8083/connectors

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

curl http://localhost:8083/connectors

# ----------------------------------------------------------------------------------------

curl http://localhost:8083/connectors/file-source | jq

# ----------------------------------------------------------------------------------------

curl http://localhost:8083/connectors/file-source/status | jq

# ----------------------------------------------------------------------------------------

curl -X POST http://localhost:8083/connectors/file-source/restart

# ----------------------------------------------------------------------------------------

curl -X PUT http://localhost:8083/connectors/file-source/config \
  -H "Content-Type: application/json" \
  -d '{
    "connector.class": "FileStreamSource",
    "tasks.max": "1",
    "file": "/input/input.txt",
    "topic": "file-topic",
    "transforms": "addSource",
    "transforms.addSource.type": "org.apache.kafka.connect.transforms.InsertField$Value",
    "transforms.addSource.static.field": "source",
    "transforms.addSource.static.value": "kafka-connect"
  }'

# ----------------------------------------------------------------------------------------

curl http://localhost:8083/connectors/file-source | jq

# ----------------------------------------------------------------------------------------

curl http://localhost:8083/connectors/file-source/tasks | jq

# ----------------------------------------------------------------------------------------

curl -X DELETE http://localhost:8083/connectors/file-source

# ----------------------------------------------------------------------------------------

curl http://localhost:8083/connectors

# ----------------------------------------------------------------------------------------

curl http://localhost:8083/connector-plugins | jq


