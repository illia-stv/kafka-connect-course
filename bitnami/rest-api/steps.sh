# ----------------------------------------------------------------------------------------
# ▶ List all connectors
# This command retrieves all deployed Kafka Connect connectors.
curl http://localhost:8083/connectors

# ----------------------------------------------------------------------------------------
# ▶ Deploy File Source Connector
# Creates a FileStreamSource connector to read data from /input/input.txt
# and write it to the "file-topic" topic.
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
# ▶ List all connectors again
# Verifies if the "file-source" connector was successfully created.
curl http://localhost:8083/connectors

# ----------------------------------------------------------------------------------------
# ▶ Get connector configuration
# Displays the current configuration of the "file-source" connector in a readable JSON format.
curl http://localhost:8083/connectors/file-source | jq

# ----------------------------------------------------------------------------------------
# ▶ Get connector status
# Checks the "file-source" connector status (e.g., RUNNING, FAILED) and its tasks.
curl http://localhost:8083/connectors/file-source/status | jq

# ----------------------------------------------------------------------------------------
# ▶ Restart connector
# Restarts the "file-source" connector in case of errors or failed tasks.
curl -X POST http://localhost:8083/connectors/file-source/restart

# ----------------------------------------------------------------------------------------
# ▶ Update connector configuration
# Modifies the "file-source" connector to add a static field transform ("source": "kafka-connect").
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
# ▶ Get updated connector configuration
# Confirms that the transform was applied to the "file-source" connector.
curl http://localhost:8083/connectors/file-source | jq

# ----------------------------------------------------------------------------------------
# ▶ List connector tasks
# Displays tasks for the "file-source" connector, useful for debugging task failures.
curl http://localhost:8083/connectors/file-source/tasks | jq

# ----------------------------------------------------------------------------------------
# ▶ Delete connector
# Removes the "file-source" connector from Kafka Connect.
curl -X DELETE http://localhost:8083/connectors/file-source

# ----------------------------------------------------------------------------------------
# ▶ List connectors after deletion
# Confirms that the "file-source" connector was successfully removed.
curl http://localhost:8083/connectors

# ----------------------------------------------------------------------------------------
# ▶ List available connector plugins
# Displays all available connector plugins that can be used in this Kafka Connect environment.
curl http://localhost:8083/connector-plugins | jq
