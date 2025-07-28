# Create Python virtual environment
# → Equivalent: make venv
python3 -m venv venv

# ----------------------------------------------------------------------------------------

# Activate the virtual environment (manual step, not needed in Makefile rules)
source ./venv/bin/activate

# ----------------------------------------------------------------------------------------

# Install Python dependencies
# → Equivalent: make install
pip install kafka-python

# ----------------------------------------------------------------------------------------

# Connect to Postgres container shell
# → Equivalent: make psql
docker exec -it $(docker ps --filter "name=postgres" --format "{{.Names}}") psql -U kafka -d kafkadb

# ----------------------------------------------------------------------------------------

# Create 'logs' table in Postgres
# → Equivalent: make create-table
CREATE TABLE logs (
  level TEXT,
  message TEXT,
  timestamp DOUBLE PRECISION
);

# ----------------------------------------------------------------------------------------

# Produce sample Kafka messages
# → Equivalent: make produce
python3 kafka_producer.py

# ----------------------------------------------------------------------------------------

# Deploy JDBC Sink connector
# → Equivalent: make deploy-connector
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "jdbc-sink-connector",
    "config": {
      "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
      "tasks.max": "1",
      "topics": "logs",
      "connection.url": "jdbc:postgresql://postgres:5432/kafkadb",
      "connection.user": "kafka",
      "connection.password": "kafka",
      "insert.mode": "insert",
      "pk.mode": "none",
      "delete.enabled": "false",
      "auto.create": "false",
      "auto.evolve": "false",
      "table.name.format": "logs",
      "key.ignore": "true",
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter.schemas.enable": "true"
    }
  }'

# ----------------------------------------------------------------------------------------

# Query data from 'logs' table
# → Equivalent: make view-logs
SELECT * FROM logs;
