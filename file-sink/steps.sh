# ----------------------------------------------------------------------------------------
# ▶ Deploy File Source Connector
# This connector reads data from a local file inside the Kafka Connect container (/input/input.txt)
# and publishes each line as a message into the "file-topic" Kafka topic.

curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "file-source",                  # Unique connector name for the source
    "config": {
      "connector.class": "FileStreamSource", # Built-in connector class for reading files
      "tasks.max": "1",                      # Number of parallel tasks
      "file": "/input/input.txt",            # Input file path inside the container
      "topic": "file-topic"                  # Kafka topic where file data will be published
    }
  }'

# ----------------------------------------------------------------------------------------
# ▶ Deploy File Sink Connector
# This connector consumes data from the "file-topic" Kafka topic
# and writes it into a local file inside the Kafka Connect container (/output/output.txt).

curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "file-sink",                    # Unique connector name for the sink
    "config": {
      "connector.class": "FileStreamSink",  # Built-in connector class for writing to files
      "tasks.max": "1",                     # Number of parallel tasks
      "topics": "file-topic",               # Kafka topic to consume messages from
      "file": "/output/output.txt"          # Output file path inside the container
    }
  }'

# ----------------------------------------------------------------------------------------
