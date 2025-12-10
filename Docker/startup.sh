#!/bin/bash
# docker/startup.sh

echo "Starting Cloud Migration Pipeline..."

# Start Zookeeper
/opt/kafka/bin/zookeeper-server-start.sh -daemon /opt/kafka/config/zookeeper.properties
sleep 5

# Start Kafka
/opt/kafka/bin/kafka-server-start.sh -daemon /opt/kafka/config/server.properties
sleep 10

# Create topics
/opt/kafka/bin/kafka-topics.sh --create --topic cloud-stream --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
/opt/kafka/bin/kafka-topics.sh --create --topic student-analytics --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1

# Start NiFi
/opt/nifi/bin/nifi.sh start
sleep 20

# Run Python apps
echo "Starting Python applications..."
python3 kafka_producer/producer.py &
python3 kafka_consumer/consumer.py &

# Keep container running
tail -f /dev/null
