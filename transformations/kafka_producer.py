from kafka import KafkaProducer
import json
import time
import logging
import random

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("log_producer")

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
    timestamp = int((time.time() - diff_seconds) * 1000)

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

    return {
        "level": level,
        "message": message,
        "timestamp": timestamp,
        "email": "user@example.com"
    }

# Send batches to Kafka
def send_log_batches(topic, num_batches=1, batch_size=1):
    for i in range(num_batches):
        logger.info(f"Sending batch {i + 1}/{num_batches}")
        for _ in range(batch_size):
            log_event = generate_log_message()
            producer.send(topic, value=log_event)
        producer.flush()
        time.sleep(1)

# Entry point
if __name__ == "__main__":
    topic = "logs"
    send_log_batches(topic)
    producer.close()
