# ----------------------------------------------------------------------------------------
# ▶ Start Docker containers with rebuild
# Builds images (if needed) and starts all services defined in the docker-compose.yml file.
docker compose up --build 

# ----------------------------------------------------------------------------------------
# ▶ Deploy File Source Connector
# This connector reads data from a local file inside the Kafka Connect container (/input/input.txt)
# and publishes each line as a message into the "file-topic" Kafka topic.

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
# ▶ List connectors after deletion
# Confirms that the "file-source" connector was successfully removed.
curl http://localhost:8083/connectors

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
# ▶ Deploy File Sink Connector
# This connector consumes data from the "file-topic" Kafka topic
# and writes it into a local file inside the Kafka Connect container (/output/output.txt).

curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "file-sink",
    "config": {
      "connector.class": "FileStreamSink",
      "tasks.max": "1",
      "topics": "file-topic",
      "file": "/output/output.txt"
    }
  }'

# ----------------------------------------------------------------------------------------
# ▶ List connectors after deletion
# Confirms that the "file-source" connector was successfully removed.
curl http://localhost:8083/connectors

# ----------------------------------------------------------------------------------------
# ▶ Stop and remove Docker containers and volumes
# Shuts down all running containers and removes their associated volumes.
docker compose down -v
# ----------------------------------------------------------------------------------------
