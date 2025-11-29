#!/bin/bash
# infrastructure/docker/init/elasticsearch-init-security.sh

set -e

ELASTICSEARCH_URL="http://elasticsearch:9200"
USERNAME="elastic"
PASSWORD="${ELASTIC_PASSWORD:-elasticpass123}"

echo "Waiting for Elasticsearch to be healthy..."
until curl -s -u "${USERNAME}:${PASSWORD}" "${ELASTICSEARCH_URL}/_cluster/health" | grep -q '"status":"green\|yellow"'; do
  echo "Elasticsearch not ready yet, sleeping 5s..."
  sleep 5
done

echo "Elasticsearch is up! Setting up security & index templates..."

# 1. Tạo role cho Spark write
curl -s -u "${USERNAME}:${PASSWORD}" -X PUT "${ELASTICSEARCH_URL}/_security/role/spark_writer" -H 'Content-Type: application/json' -d '{
  "cluster": ["manage_index_templates", "monitor"],
  "indices": {
    "*": {
      "privileges": ["all"]
    }
  }
}'

# 2. Tạo user dành riêng cho Spark (khuyến khích, không dùng elastic user)
curl -s -u "${USERNAME}:${PASSWORD}" -X PUT "${ELASTICSEARCH_URL}/_security/user/spark_user" -H 'Content-Type: application/json' -d '{
  "password": "spark123456",
  "roles": ["spark_writer", "kibana_admin"]
}'

# 3. Tạo index template cho sensors-data (tối ưu streaming)
curl -s -u "${USERNAME}:${PASSWORD}" -X PUT "${ELASTICSEARCH_URL}/_index_template/sensors_template" -H 'Content-Type: application/json' -d '{
  "index_patterns": ["sensors-*", "sensors_index"],
  "template": {
    "settings": {
      "number_of_shards": 3,
      "number_of_replicas": 0,
      "refresh_interval": "5s",
      "index.lifecycle.name": "7days_policy",
      "index.mapping.total_fields.limit": 2000
    },
    "mappings": {
      "dynamic": "strict",
      "properties": {
        "timestamp": { "type": "date" },
        "device_id": { "type": "keyword" },
        "temperature": { "type": "float" },
        "humidity": { "type": "float" },
        "location": { "type": "geo_point" }
      }
    }
  }
}'

echo "Elasticsearch security & templates initialized!"
echo "Spark user: spark_user / spark123456"