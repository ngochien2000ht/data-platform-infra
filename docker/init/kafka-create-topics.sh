#!/bin/bash
# infrastructure/docker/init/kafka-create-topics.sh

set -e

echo "Waiting for Kafka to be ready..."
cub kafka-ready -b kafka:9092 1 30

echo "Creating Kafka topics..."

kafka-topics --create --if-not-exists \
  --bootstrap-server kafka:9092 \
  --replication-factor 1 \
  --partitions 6 \
  --config cleanup.policy=compact \
  --topic __consumer_offsets

kafka-topics --create --if-not-exists \
  --bootstrap-server kafka:9092 \
  --replication-factor 1 \
  --partitions 12 \
  --config retention.ms=604800000 \      # 7 ngày
  --config cleanup.policy=delete \
  --topic sensors-data

kafka-topics --create --if-not-exists \
  --bootstrap-server kafka:9092 \
  --replication-factor 1 \
  --partitions 12 \
  --topic processed-data

kafka-topics --create --if-not-exists \
  --bootstrap-server kafka:9092 \
  --replication-factor 1 \
  --partitions 3 \
  --topic dlq-topic

echo "All topics created successfully!"
echo "List topics:"
kafka-topics --bootstrap-server kafka:9092 --list