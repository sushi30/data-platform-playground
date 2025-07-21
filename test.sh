#!/bin/bash

echo "Testing PostgreSQL deployment..."

# Test 1: Check if container is running
echo "1. Checking container status..."
docker-compose ps postgres

# Test 2: Test connection to main database
echo "2. Testing OpenMetadata database connection..."
docker-compose exec postgres psql -U openmetadata -d openmetadata -c "SELECT version();"

# Test 3: List all databases
echo "3. Listing all databases..."
docker-compose exec postgres psql -U openmetadata -d openmetadata -c "\l"

# Test 4: Test other database connections
echo "4. Testing Airflow database..."
docker-compose exec postgres psql -U airflow -d airflow -c "SELECT current_database();"

echo "5. Testing Superset database..."
docker-compose exec postgres psql -U superset -d superset -c "SELECT current_database();"

echo "6. Testing Metabase database..."
docker-compose exec postgres psql -U metabase -d metabase -c "SELECT current_database();"

# Test 7: Check port accessibility from host
echo "7. Testing port accessibility..."
nc -zv localhost 5432

echo "All tests completed!"