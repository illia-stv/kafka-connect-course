python3 -m venv venv

# ----------------------------------------------------------------------------------------

source ./venv/bin/activate

# ----------------------------------------------------------------------------------------

pip install kafka-python

# ----------------------------------------------------------------------------------------

python3 kafka_producer.py

# ----------------------------------------------------------------------------------------

curl -X POST http://localhost:8083/connectors   -H "Content-Type: application/json"   -d '{
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

docker ps

# ----------------------------------------------------------------------------------------


docker exec -it <postgres_container_name> psql -U kafka -d kafkadb

# ----------------------------------------------------------------------------------------

CREATE TABLE logs (
  level TEXT,
  message TEXT,
  timestamp DOUBLE PRECISION
);

# ----------------------------------------------------------------------------------------

SELECT * FROM logs;
