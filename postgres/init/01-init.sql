-- Create users first (before creating databases)
CREATE USER airflow_user WITH PASSWORD 'airflow_password';
CREATE USER superset_user WITH PASSWORD 'superset_password';
CREATE USER openmetadata_user WITH PASSWORD 'openmetadata_password';
CREATE USER dbt_user WITH PASSWORD 'dbt_password';

-- Create additional databases for demo with proper ownership
-- Note: 'openmetadata' user already exists from POSTGRES_USER env var
CREATE DATABASE openmetadata_db OWNER openmetadata_user;
CREATE DATABASE airflow_db OWNER airflow_user;
CREATE DATABASE superset_db OWNER superset_user;   
CREATE DATABASE jaffle_db OWNER dbt_user;

-- Note: Database ownership is set above, no additional permissions needed
-- The openmetadata user (from docker-compose env) will use openmetadata_db owned by openmetadata
-- Other services will use their respective databases owned by their users