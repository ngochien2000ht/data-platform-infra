#!/bin/sh
set -e

# Thêm alias
mc alias set myminio http://minio:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD

# Tạo bucket
mc mb myminio/streaming-data || true

# Tạo policy
mc admin policy add myminio ingestion-policy /docker-entrypoint-init.d/policies/ingestion-policy.json || true
mc admin policy add myminio read-only-policy /docker-entrypoint-init.d/policies/read-only-policy.json || true

# Tạo user & gán policy
mc admin user add myminio spark_user Spark#123 || true
mc admin group add myminio writers spark_user || true
mc admin policy set myminio ingestion-policy group=writers || true