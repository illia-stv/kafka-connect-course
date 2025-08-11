# ----------------------------------------------------------------------------------------
# Create Python virtual environment
# This will create an isolated Python environment in the "venv" directory
# so dependencies installed here won’t affect your system-wide Python packages.
# → Equivalent: make venv
python3 -m venv venv

# ----------------------------------------------------------------------------------------
# Activate the virtual environment
# This makes your shell use Python and pip from the venv directory instead of global ones.
# → Equivalent: make activate
source ./venv/bin/activate

# ----------------------------------------------------------------------------------------
# Install Python dependencies
# Installing kafka-python so we can produce Kafka messages from a Python script.
# → Equivalent: make install
pip install kafka-python

# ----------------------------------------------------------------------------------------
# ▶ Start Docker containers with rebuild
# Builds images (if needed) and starts all services from docker-compose.yml
# This will bring up Zookeeper, Kafka, Kafka Connect, Elasticsearch, and Kibana.
docker compose up --build 

# ----------------------------------------------------------------------------------------
# Run Python producer script
# Produces random messages into the "logs" topic for testing the connector.
python3 kafka_producer.py

# ----------------------------------------------------------------------------------------
# Open an interactive shell inside the Kafka container
# Useful for running kafka-console-producer or kafka-console-consumer commands.
docker exec -it kafka bash

# ----------------------------------------------------------------------------------------
# Start Kafka Console Producer (inside the Kafka container)
# Allows you to type messages manually into the "logs" topic.
kafka-console-producer.sh --broker-list kafka:9092 --topic logs

# ----------------------------------------------------------------------------------------
# Create Elasticsearch Sink Connector (no DLQ)
# This connector reads from the "logs" topic and writes documents into Elasticsearch.
# It ignores message keys, enforces schema usage, and uses JSON serialization.
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "elasticsearch-sink-connector",
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
# ▶ Get connector status
# Checks the "elasticsearch-sink-connector" connector status (e.g., RUNNING, FAILED) and its tasks.
curl http://localhost:8083/connectors/elasticsearch-sink-connector/status | jq

# ----------------------------------------------------------------------------------------
# ▶ Delete connector
# Removes the "elasticsearch-sink-connector" from Kafka Connect so we can re-create it.
curl -X DELETE http://localhost:8083/connectors/elasticsearch-sink-connector

# ----------------------------------------------------------------------------------------
# Create Elasticsearch Sink Connector (with DLQ support)
# Same as before, but now includes error handling and Dead Letter Queue configuration.
# - errors.tolerance=all → skip bad records instead of failing
# - errors.log.enable=true → log details of errors
# - errors.deadletterqueue.topic.name=dlq-topic → send failed records here
# - errors.deadletterqueue.context.headers.enable=true → include metadata in DLQ
# - errors.deadletterqueue.topic.replication.factor=1 → set DLQ replication factor
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "elasticsearch-sink-connector",
    "config": {
      "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
      "tasks.max": "1",
      "topics": "logs",
      "connection.url": "http://elasticsearch:9200",
      "key.ignore": "true",
      "schema.ignore": "false",
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter.schemas.enable": "true",
      "behavior.on.null.values": "ignore",
      "errors.tolerance": "all",
      "errors.log.enable": "true",
      "errors.deadletterqueue.topic.name": "dlq-topic",
      "errors.deadletterqueue.context.headers.enable": "true",
      "errors.deadletterqueue.topic.replication.factor": "1"
    }
  }'


# ----------------------------------------------------------------------------------------
# ▶ Get connector status
# Checks the "elasticsearch-sink-connector" connector status (e.g., RUNNING, FAILED) and its tasks.
curl http://localhost:8083/connectors/elasticsearch-sink-connector/status | jq  

# ----------------------------------------------------------------------------------------
# Elasticsearch dashboard (Kibana)
# Check that records from Kafka are being indexed into Elasticsearch as expected.
# Kibana URL: http://localhost:5601/app/dev_tools#/console
# Run this to see documents from the "logs" index:
GET /logs/_search

# ----------------------------------------------------------------------------------------
# Run Python producer script
# Produces random messages into the "logs" topic for testing the connector.
python3 kafka_producer.py

# ----------------------------------------------------------------------------------------
# Enter Kafka container again (optional)
# Can be used to run console producer/consumer for testing after enabling DLQ.
docker exec -it kafka bash

# ----------------------------------------------------------------------------------------
# Consume Dead Letter Queue messages
# Reads records from the "dlq-topic" that failed to process in the connector.
kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic dlq-topic --from-beginning

# ----------------------------------------------------------------------------------------
# Shut down Docker containers and remove volumes
# -v ensures stored data (like Kafka logs) is removed for a clean restart next time.
docker compose down -v

# ----------------------------------------------------------------------------------------
