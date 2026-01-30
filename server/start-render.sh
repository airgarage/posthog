#!/bin/bash
set -e

# Wait for ClickHouse to be ready and create database/table if missing
# This fixes the "Code: 60" error on fresh installs
echo "Checking ClickHouse connectivity..."
curl -s -X POST 'http://posthog-clickhouse:8123/?query=CREATE%20DATABASE%20IF%20NOT%20EXISTS%20posthog' || echo "ClickHouse DB init failed (might already exist)"
curl -s -X POST 'http://posthog-clickhouse:8123/?query=CREATE%20TABLE%20IF%20NOT%20EXISTS%20posthog.infi_clickhouse_orm_migrations%20(package_name%20String,%20module_name%20String,%20applied%20Date)%20ENGINE%20=%20MergeTree(applied,%20(package_name,%20module_name),%208192)' || echo "ClickHouse migrations table init failed (might already exist)"

echo "Running migrations..."
./bin/docker-migrate

echo "Starting server..."
./bin/docker-server
