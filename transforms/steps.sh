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

curl -X POST http://localhost:8083/connectors   -H "Content-Type: application/json"   -d '{
    "name": "logs-file-sink",
    "config": {
      "connector.class": "FileStreamSink",
      "tasks.max": "1",
      "topics": "logs",
      "file": "/output/logs-output.txt",

      "key.converter": "org.apache.kafka.connect.storage.StringConverter",
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter.schemas.enable": "false",

      "transforms": "addSource",
      "transforms.addSource.type": "org.apache.kafka.connect.transforms.InsertField$Value",
      "transforms.addSource.static.field": "source",
      "transforms.addSource.static.value": "kafka-connect"
    }
  }'

# ----------------------------------------------------------------------------------------

python3 kafka_producer.py

# ----------------------------------------------------------------------------------------

curl -X DELETE http://localhost:8083/connectors/logs-file-sink

# ----------------------------------------------------------------------------------------

curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "logs-file-sink-filtered",
    "config": {
      "connector.class": "FileStreamSink",
      "tasks.max": "1",
      "topics": "logs",
      "file": "/output/logs-filtered.txt",

      "key.converter": "org.apache.kafka.connect.storage.StringConverter",
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter.schemas.enable": "false",

      "transforms": "filterFields",
      "transforms.filterFields.type": "org.apache.kafka.connect.transforms.ReplaceField$Value",
      "transforms.filterFields.include": "message,timestamp"
    }
  }'

# ----------------------------------------------------------------------------------------

curl -X DELETE http://localhost:8083/connectors/logs-file-sink-filtered

# ----------------------------------------------------------------------------------------

curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "masked-logs-sink",
    "config": {
      "connector.class": "FileStreamSink",
      "tasks.max": "1",
      "topics": "logs",
      "file": "/output/masked-logs.txt",

      "key.converter": "org.apache.kafka.connect.storage.StringConverter",
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter.schemas.enable": "false",

      "transforms": "maskEmail",
      "transforms.maskEmail.type": "org.apache.kafka.connect.transforms.MaskField$Value",
      "transforms.maskEmail.fields": "email"
    }
  }'

# ----------------------------------------------------------------------------------------

curl -X DELETE http://localhost:8083/connectors/masked-logs-sink

# ----------------------------------------------------------------------------------------

curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "logs-timestamp-converted",
    "config": {
      "connector.class": "FileStreamSink",
      "tasks.max": "1",
      "topics": "logs",
      "file": "/output/logs-readable-time.txt",

      "key.converter": "org.apache.kafka.connect.storage.StringConverter",
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter.schemas.enable": "false",

      "transforms": "convertTimestamp",
      "transforms.convertTimestamp.type": "org.apache.kafka.connect.transforms.TimestampConverter$Value",
      "transforms.convertTimestamp.field": "timestamp",
      "transforms.convertTimestamp.target.type": "string",
      "transforms.convertTimestamp.format": "yyyy-MM-dd HH:mm:ss"
    }
  }'

# ----------------------------------------------------------------------------------------

curl -X DELETE http://localhost:8083/connectors/logs-timestamp-converted

# ----------------------------------------------------------------------------------------

deactivate