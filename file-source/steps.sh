# ----------------------------------------------------------------------------------------
# ▶ Deploy File Source Connector
# This connector reads data from a file inside the Kafka Connect container (/input/input.txt)
# and writes each line as a message into the "file-topic" Kafka topic.

curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "file-source",                  # Unique connector name for the source
    "config": {
      "connector.class": "FileStreamSource", # Connector class for reading files
      "tasks.max": "1",                      # Number of parallel tasks
      "file": "/input/input.txt",            # Path of input file inside container
      "topic": "file-topic"                  # Kafka topic to publish messages
    }
  }'

# ----------------------------------------------------------------------------------------
# ▶ Access Kafka container
# This command opens an interactive shell session inside the running Kafka container.
# Useful for running Kafka CLI tools such as kafka-console-producer or kafka-console-consumer.

docker exec -it kafka bash

# ----------------------------------------------------------------------------------------
# ▶ Consume messages from Kafka topic
# This command consumes and displays all messages from the "file-topic" Kafka topic.
# The '--from-beginning' flag ensures it reads all existing messages, not just new ones.

kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic file-topic --from-beginning

# ----------------------------------------------------------------------------------------
