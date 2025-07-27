docker compose up

# ----------------------------------------------------------------------------------------

python3 -m venv venv

# or it could be

python -m venv venv

# depends on your version of python

# ----------------------------------------------------------------------------------------

source ./venv/bin/activate

# ----------------------------------------------------------------------------------------

pip install kafka-python

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
      "behavior.on.null.values": "ignore"
    }
  }'