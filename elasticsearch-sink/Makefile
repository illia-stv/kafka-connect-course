# Makefile to automate Kafka Connect → Elasticsearch Sink setup with Bitnami/Confluent stack

# ----------------------------------------------------------------------------------------
# Variables
PYTHON_BIN := $(shell command -v python3 || command -v python)
CONNECTOR_NAME := elasticsearch-sink-connector

# ----------------------------------------------------------------------------------------
# Setup Python virtual environment
venv:
	$(PYTHON_BIN) -m venv venv
	@echo "✅ Virtual environment created."

# ----------------------------------------------------------------------------------------
# Activate the virtual environment (manual step, but formalized here)
activate: venv
	@echo "✅ To activate the virtual environment, run:"
	@echo "   source ./venv/bin/activate"

# ----------------------------------------------------------------------------------------
# Install Python dependencies inside venv (requires manual activation beforehand)
install:
	pip install kafka-python
	@echo "✅ Python dependencies installed."

# ----------------------------------------------------------------------------------------
# Produce structured log messages into Kafka topic
produce:
	$(PYTHON_BIN) kafka_producer.py
	@echo "✅ Log messages sent to Kafka topic."

# ----------------------------------------------------------------------------------------
# Deploy Elasticsearch Sink Connector
deploy-connector:
	echo '{ \
	  "name": "$(CONNECTOR_NAME)", \
	  "config": { \
	    "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector", \
	    "tasks.max": "1", \
	    "topics": "logs", \
	    "connection.url": "http://elasticsearch:9200", \
	    "key.ignore": "true", \
	    "schema.ignore": "false", \
	    "value.converter": "org.apache.kafka.connect.json.JsonConverter", \
	    "value.converter.schemas.enable": "true", \
	    "behavior.on.null.values": "ignore" \
	  } \
	}' | \
	curl -X POST http://localhost:8083/connectors \
	     -H "Content-Type: application/json" \
	     -d @-
	@echo "✅ Elasticsearch Sink connector deployed."

# ----------------------------------------------------------------------------------------
# Start Docker containers with rebuild
up:
	docker compose up --build -d
	@echo "✅ Docker containers started."

# ----------------------------------------------------------------------------------------
# Stop and remove Docker containers and volumes
down:
	docker compose down -v
	@echo "✅ Docker containers and volumes removed."

# ----------------------------------------------------------------------------------------
# Clean up connector from Kafka Connect
delete-connector:
	curl -X DELETE http://localhost:8083/connectors/$(CONNECTOR_NAME)
	@echo "🗑️  Connector '$(CONNECTOR_NAME)' removed."

# ----------------------------------------------------------------------------------------
# Full setup workflow
all: install produce deploy-connector
	@echo "✅ All steps completed successfully."

.PHONY: venv install produce deploy-connector up down all delete-connector
