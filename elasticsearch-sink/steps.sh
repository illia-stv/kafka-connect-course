# ----------------------------------------------------------------------------------------
# ▶ Equivalent Makefile command: make up

# Start all Docker services (Kafka, Zookeeper, Kafka Connect, Elasticsearch, etc.)
docker compose up

# ----------------------------------------------------------------------------------------
# ▶ Equivalent Makefile command: make venv

# Create a Python virtual environment for isolated dependencies
# This ensures consistent behavior for Kafka producer scripts
python3 -m venv venv

# or (depending on Python installation):
# python -m venv venv

# ----------------------------------------------------------------------------------------
# ▶ Equivalent Makefile command: make activate

# Activate the virtual environment
# This must be run manually before using pip or running Python scripts inside the venv
source ./venv/bin/activate

# ----------------------------------------------------------------------------------------
# ▶ Equivalent Makefile command: make install

# Install Python Kafka client inside the virtual environment
# Required by the kafka_producer.py script
pip install kafka-python

# ----------------------------------------------------------------------------------------
# ▶ Equivalent Makefile command: make produce

# Run the Kafka producer script
# Sends structured JSON log messages to Kafka topic "logs"
python3 kafka_producer.py

# ----------------------------------------------------------------------------------------
# ▶ Equivalent Makefile command: make deploy-connector

# Deploy the Elasticsearch Sink Connector to Kafka Connect via REST API
# It reads messages from Kafka topic "logs" and indexes them into Elasticsearch
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "elasticsearch-sink-connector",  # Unique connector name
    "config": {
      "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
      "tasks.max": "1",
      "topics": "logs",
      "connection.url": "http://elasticsearch:9200",
      "key.ignore": "true",
      "schema.ignore": "false",
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter.schemas.enable": "true",
      "behavior.on.null.values": "ignore"
    }
  }'

# ----------------------------------------------------------------------------------------

#  Link to Elasticsearch dashboard: http://localhost:5601/app/dev_tools#/console

# Paste this command:
GET /logs/_search
