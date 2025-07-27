from kafka import KafkaProducer
import json
import time
import logging
import random

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("log_producer")

# Define the schema for Kafka Connect
log_schema = {
    "type": "struct",
    "fields": [
        {"type": "string", "optional": True, "field": "level"},
        {"type": "string", "optional": True, "field": "message"},
        {"type": "double", "optional": True, "field": "timestamp"}
    ],
    "optional": False,
    "name": "log_message"
}

# Kafka producer setup
producer = KafkaProducer(
    bootstrap_servers=["localhost:9093"],
    value_serializer=lambda x: json.dumps(x).encode("utf-8"),
    batch_size=16384,
    linger_ms=10,
    acks="all",
)

# Generate log content
def generate_log_message():
    diff_seconds = random.uniform(300, 600)
    timestamp = time.time() - diff_seconds

    log_messages = {
        "INFO": [
            "User login successful",
            "Database connection established",
            "Service started",
            "Payment processed",
        ],
        "WARNING": ["Service stopped", "Payment may not have been processed"],
        "ERROR": ["User login failed", "Database connection failed", "Payment failed"],
        "DEBUG": ["Debugging user login flow", "Debugging database connection"],
    }

    level = random.choice(list(log_messages.keys()))
    message = random.choice(log_messages[level])

    return {"level": level, "message": message, "timestamp": timestamp}

# Wrap log message in schema + payload
def generate_structured_message():
    payload = generate_log_message()
    return {
        "schema": log_schema,
        "payload": payload
    }

# Send batches to Kafka
def send_log_batches(topic, num_batches=1, batch_size=1):
    for i in range(num_batches):
        logger.info(f"Sending batch {i + 1}/{num_batches}")
        for _ in range(batch_size):
            structured = generate_structured_message()
            producer.send(topic, value=structured)
        producer.flush()
        time.sleep(1)

# Entry point
if __name__ == "__main__":
    topic = "logs"
    send_log_batches(topic)
    producer.close()
