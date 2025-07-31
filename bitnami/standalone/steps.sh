# ----------------------------------------------------------------------------------------
# ▶ Access Kafka container shell
# Opens an interactive bash shell session inside the running Kafka container.
docker exec -it kafka bash

# ----------------------------------------------------------------------------------------
# ▶ Consume messages from topic
# Starts a Kafka console consumer that reads messages from the "file-input" topic.
# The "--from-beginning" flag ensures it reads all existing messages from the beginning.
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic file-input --from-beginning

# ----------------------------------------------------------------------------------------
