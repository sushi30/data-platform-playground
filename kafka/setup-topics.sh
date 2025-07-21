#!/bin/bash
# Create OpenLineage topic for dbt lineage events
set -e

echo "Creating OpenLineage topic..."

kafka-topics --create \
  --if-not-exists \
  --bootstrap-server kafka:29092 \
  --topic openlineage.events \
  --partitions 3 \
  --replication-factor 1 \
  --config retention.ms=604800000 \
  --config compression.type=gzip

echo "OpenLineage topic created successfully!"

# List all topics to verify
echo "Current Kafka topics:"
kafka-topics --bootstrap-server kafka:29092 --list
