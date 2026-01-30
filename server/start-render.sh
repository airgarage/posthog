#!/bin/bash
set -e

# Wait for ClickHouse to be ready and create database/table if missing
# This fixes the "Code: 60" error on fresh installs
echo "Checking ClickHouse connectivity..."

# Fix: Use --data-binary to avoid Code 381 (Length Required) errors
curl -s -X POST 'http://posthog-clickhouse:8123/' --data-binary 'CREATE DATABASE IF NOT EXISTS posthog' || echo "ClickHouse DB init failed"

# Create the base migrations table
curl -s -X POST 'http://posthog-clickhouse:8123/' --data-binary "CREATE TABLE IF NOT EXISTS posthog.infi_clickhouse_orm_migrations (package_name String, module_name String, applied Date) ENGINE = MergeTree(applied, (package_name, module_name), 8192)" || echo "ClickHouse migrations table init failed"

# Create the distributed table wrapper (required because PostHog defaults to replicated=True)
# We map it to the local table since we are in a single-node setup
curl -s -X POST 'http://posthog-clickhouse:8123/' --data-binary "CREATE TABLE IF NOT EXISTS posthog.infi_clickhouse_orm_migrations_distributed AS posthog.infi_clickhouse_orm_migrations ENGINE = Distributed('posthog', 'posthog', 'infi_clickhouse_orm_migrations', rand())" || echo "ClickHouse distributed migrations table init failed (might fail if cluster config is missing, but that is okay)"

echo "Running migrations..."
./bin/docker-migrate

echo "Starting server..."
./bin/docker-server