# Create Python virtual environment
# → Equivalent: make venv
python3 -m venv venv

# ----------------------------------------------------------------------------------------

# Activate the virtual environment (manual step, not needed in Makefile rules)
# → Equivalent: make activate
source ./venv/bin/activate

# ----------------------------------------------------------------------------------------

# Install Python dependencies
# → Equivalent: make install
pip install kafka-python

# ----------------------------------------------------------------------------------------

# ▶ Start Docker containers with rebuild
# Builds images (if needed) and starts all services defined in the docker-compose.yml file.
docker compose up --build 

# ----------------------------------------------------------------------------------------

docker exec -it kafka bash

# ----------------------------------------------------------------------------------------

kafka-console-producer.sh --broker-list kafka:9092 --topic logs

# ----------------------------------------------------------------------------------------

{"id": 1, "message": "valid record"}
BAD_JSON_LINE
{"id": 2, "message": "another valid record"}

# ----------------------------------------------------------------------------------------

python3 kafka_producer.py

# ----------------------------------------------------------------------------------------

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

#  Link to Elasticsearch dashboard: http://localhost:5601/app/dev_tools#/console

# Paste this command:
GET /logs/_search

# ----------------------------------------------------------------------------------------

docker exec -it kafka-connect cat /output/sink-output.txt

# ----------------------------------------------------------------------------------------

kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic dlq-topic --from-beginning

# ----------------------------------------------------------------------------------------

docker compose down -v

# ----------------------------------------------------------------------------------------