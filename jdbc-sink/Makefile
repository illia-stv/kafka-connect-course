# Makefile to automate Kafka Connect → Postgres JDBC Sink setup with Bitnami stack

# ----------------------------------------------------------------------------------------
# Variables
POSTGRES_CONTAINER=$(shell docker ps --filter "name=postgres" --format "{{.Names}}")

# ----------------------------------------------------------------------------------------
# Setup Python virtual environment
venv:
	python3 -m venv venv
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
# Open interactive Postgres shell inside container
psql:
	docker exec -it $(POSTGRES_CONTAINER) psql -U kafka -d kafkadb

# ----------------------------------------------------------------------------------------
# Create 'logs' table in Postgres
create-table:
	printf "CREATE TABLE IF NOT EXISTS logs (\n  level TEXT,\n  message TEXT,\n  timestamp DOUBLE PRECISION\n);\n" | \
	docker exec -i $(POSTGRES_CONTAINER) psql -U kafka -d kafkadb
	@echo "✅ Table 'logs' created if not exists."

# ----------------------------------------------------------------------------------------
# Produce structured log messages into Kafka topic
produce:
	python3 kafka_producer.py
	@echo "✅ Log messages sent to Kafka topic."

# ----------------------------------------------------------------------------------------
# Deploy JDBC Sink connector to Kafka Connect
deploy-connector:
	echo '{ \
	    "name": "jdbc-sink-connector", \
	    "config": { \
	      "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector", \
	      "tasks.max": "1", \
	      "topics": "logs", \
	      "connection.url": "jdbc:postgresql://postgres:5432/kafkadb", \
	      "connection.user": "kafka", \
	      "connection.password": "kafka", \
	      "insert.mode": "insert", \
	      "pk.mode": "none", \
	      "delete.enabled": "false", \
	      "auto.create": "false", \
	      "auto.evolve": "false", \
	      "table.name.format": "logs", \
	      "key.ignore": "true", \
	      "value.converter": "org.apache.kafka.connect.json.JsonConverter", \
	      "value.converter.schemas.enable": "true" \
	    } \
	  }' | \
	curl -X POST http://localhost:8083/connectors \
	     -H "Content-Type: application/json" \
	     -d @-
	@echo "✅ JDBC Sink connector deployed."

# ----------------------------------------------------------------------------------------
# Query logs table in Postgres
view-logs:
	docker exec -i $(POSTGRES_CONTAINER) \
		psql -U kafka -d kafkadb -c "SELECT * FROM logs;"
	@echo "✅ Data queried from logs table."

# ----------------------------------------------------------------------------------------
# Start Docker services with rebuild
up:
	docker compose up --build -d
	@echo "✅ Docker containers started with --build."

# ----------------------------------------------------------------------------------------
# Stop and remove Docker containers and volumes, also deactivate virtual environment
down:
	docker compose down -v && deactivate
	@echo "✅ Docker containers and volumes removed."

# ----------------------------------------------------------------------------------------
# Full pipeline
all: install create-table produce deploy-connector view-logs
	@echo "✅ All steps completed successfully."

.PHONY: venv install psql create-table produce deploy-connector view-logs up down all
