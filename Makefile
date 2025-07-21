# OpenMetadata Demo - Makefile
# This Makefile provides automation for the OpenMetadata + dbt + Superset demo stack

# Database Services
# Start PostgreSQL database service
postgres:
	docker compose up -d postgres

# dbt Commands
# Install dbt dependencies and seed sample data from CSV files
dbt-seed:
	docker compose run --rm dbt dbt-ol seed --full-refresh --vars '{"load_source_data": true}'

# Build and test the complete dbt project (recommended for full workflow)
dbt-build:
	docker compose run --rm dbt dbt-ol build

# Run dbt models only (without tests)
dbt-run:
	docker compose run --rm dbt dbt run

# Run dbt tests only
dbt-test:
	docker compose run --rm dbt dbt test

# Generate and serve dbt documentation on port 8080
dbt-docs:
	docker compose run --rm dbt dbt docs generate
	docker compose run --rm dbt dbt docs serve --port 8080

# Superset Services
# Start Superset dashboard service (requires postgres and redis)
superset:
	docker compose up -d superset

# Rebuild Superset image (useful after configuration changes)
superset-build:
	docker compose build superset

# View Superset container logs (useful for troubleshooting)
superset-logs:
	docker compose logs -f superset

# OpenMetadata Services
# Run OpenMetadata database migrations (one-time setup)
openmetadata-migrate:
	docker compose up openmetadata-migrate

# Start OpenMetadata server with ingestion (requires postgres, elasticsearch, and migrations)
openmetadata:
	docker compose up -d openmetadata-server ingestion

# Start OpenMetadata server only (without ingestion)
openmetadata-server:
	docker compose up -d openmetadata-server

# Start OpenMetadata ingestion/Airflow service
openmetadata-ingestion:
	docker compose up -d openmetadata-ingestion

# View OpenMetadata server logs (useful for troubleshooting)
openmetadata-logs:
	docker compose logs -f openmetadata-server

# View OpenMetadata ingestion logs
openmetadata-ingestion-logs:
	docker compose logs -f openmetadata-ingestion

# View OpenMetadata migration logs
openmetadata-migrate-logs:
	docker compose logs openmetadata-migrate

# Start Elasticsearch (required for OpenMetadata)
elasticsearch:
	docker compose up -d elasticsearch

# Stack Management
# Start the complete stack (PostgreSQL + Superset DB + Redis + Superset + Elasticsearch + OpenMetadata Migration + OpenMetadata + Ingestion)
stack-up:
	docker compose up -d postgres redis superset elasticsearch
	docker compose up openmetadata-migrate
	docker compose up -d openmetadata-server openmetadata-ingestion

# Stop all services, remove containers and volumes
stack-down:
	docker compose down --remove-orphans --volumes

.PHONY: postgres dbt-seed dbt-build-project dbt-run dbt-build dbt-test dbt-docs superset superset-build superset-logs openmetadata-migrate openmetadata openmetadata-server openmetadata-ingestion openmetadata-logs openmetadata-ingestion-logs openmetadata-migrate-logs elasticsearch stack-up stack-down
