# OpenMetadata Demo

This project demonstrates integration between OpenMetadata and dbt using the Jaffle Shop example project.

## Setup

### Prerequisites

- Docker and Docker Compose
- Make (optional, for using Makefile commands)

### Quick Start

1. **Start PostgreSQL database:**
   ```bash
   make postgres
   ```

2. **Seed the dbt project with sample data:**
   ```bash
   make dbt-seed
   ```

3. **Run the dbt project:**
   ```bash
   make dbt-build-project
   ```

4. **Start Superset for dashboards:**
   ```bash
   make superset
   ```

5. **Start OpenMetadata for data lineage:**
   ```bash
   make openmetadata-migrate  # Run database migrations first
   make openmetadata          # Start the server
   ```

### Available Commands

All available commands are documented in the `Makefile`. Run `make` followed by any of these targets:

**Quick Reference:**
- `make stack-up` - Start the complete stack (includes OpenMetadata migration)
- `make dbt-seed` - Load sample data
- `make dbt-build-project` - Build dbt models and run tests
- `make superset` - Start Superset dashboards
- `make openmetadata-migrate` - Run OpenMetadata database migrations
- `make openmetadata` - Start OpenMetadata server
- `make stack-down` - Stop all services

For detailed descriptions of each command, see the comments in the `Makefile`.

### Docker Services

- **postgres**: PostgreSQL database for storing dbt data and models
- **postgres-superset**: Separate PostgreSQL database for Superset metadata
- **redis**: Redis cache for Superset
- **elasticsearch**: Elasticsearch for OpenMetadata search and indexing
- **superset**: Apache Superset for dashboards and visualization
- **openmetadata-migrate**: One-time migration service for OpenMetadata database setup
- **openmetadata-server**: OpenMetadata server for data catalog and lineage
- **dbt**: dbt Docker container for running dbt commands (one-off service, not persistent)

### Database Schema

The dbt project creates the following schemas in PostgreSQL:
- `jaffle_shop_dev` - Development environment
- `jaffle_shop_prod` - Production environment (configured but not used by default)

### Project Structure

```
├── docker-compose.yml          # Docker services configuration
├── Makefile                   # Automation commands
├── dbt-jaffle-shop/          # dbt project directory
│   ├── Dockerfile            # dbt container configuration
│   ├── profiles/             # dbt profiles configuration
│   └── ...                   # dbt project files
├── superset/                 # Superset configuration
│   └── superset_config.py    # Superset configuration file
├── openmetadata/             # OpenMetadata configuration
│   └── conf/                 # OpenMetadata server configuration
│       ├── openmetadata.yaml # Main configuration file
│       ├── public_key.der    # JWT public key
│       └── private_key.der   # JWT private key
└── postgres/                 # PostgreSQL initialization scripts
    └── init/
        └── 01-init.sql
```

## Usage

### Complete Setup Workflow

1. **Start the full stack:**
   ```bash
   make stack-up
   ```

2. **Seed dbt data:**
   ```bash
   make dbt-seed
   ```

3. **Build dbt models:**
   ```bash
   make dbt-build-project
   ```

4. **Access the services:**
   - **Superset**: http://localhost:8088 (admin/admin)
   - **OpenMetadata**: http://localhost:8585 (admin/admin)

5. **Set up data connections in both services as described in their respective configuration sections**

### Data Pipeline Overview

This setup creates a complete modern data stack:

1. **PostgreSQL** → Raw data storage
2. **dbt** → Data transformation and modeling  
3. **Superset** → Business intelligence and dashboards
4. **OpenMetadata** → Data catalog, lineage, and governance

The pipeline flow: Raw Data → dbt Transformations → Analytics Tables → Superset Dashboards + OpenMetadata Lineage

### OpenMetadata Configuration

OpenMetadata provides data catalog, lineage tracking, and data governance capabilities. Here's how to set it up:

#### Setting Up OpenMetadata

After starting the stack, follow these steps to configure OpenMetadata:

1. **Access OpenMetadata:**
   - URL: http://localhost:8585
   - Username: `admin`
   - Password: `admin`

2. **Add PostgreSQL Database Connection:**
   - Go to **Settings** > **Services** > **Databases**
   - Click **Add New Service**
   - Select **PostgreSQL** as the database type
   - Fill in the connection details:
     ```
     Service Name: postgres-jaffle-shop
     Host: postgres
     Port: 5432
     Database: jaffle_db
     Username: dbt_user
     Password: dbt_password
     ```
   - Click **Test Connection** and then **Save**

   **Note**: We connect to the `jaffle_db` database using `dbt_user` credentials because this is where dbt creates the transformed data models that we want to catalog in OpenMetadata.

3. **Configure PostgreSQL Data Ingestion:**
   - After creating the PostgreSQL service, click on it from the Services list
   - Click **Add Ingestion** 
   - Select **Metadata Ingestion**
   - Configure the ingestion settings:
     ```
     Name: postgres-jaffle-shop-metadata
     Schema Filter Pattern: 
       - Include: jaffle_shop_dev
     Table Filter Pattern: 
       - Include: .*
     ```
   - Set the schedule (e.g., daily at 2 AM): `0 2 * * *`
   - Click **Deploy** to create the ingestion pipeline

4. **Run the Initial Ingestion:**
   - Go to **Services** > **Ingestions**
   - Find your `postgres-jaffle-shop-metadata` pipeline
   - Click **Run** to execute the initial metadata ingestion
   - Monitor the progress in the **Activity** tab
   - Once complete, you should see all dbt models (customers, orders, order_items, products, locations) in the catalog

5. **Add Superset Dashboard Service:**
   - Go to **Settings** > **Services** > **Dashboard**
   - Click **Add New Service**
   - Select **Superset** as the dashboard type
   - Fill in the connection details:
     ```
     Service Name: superset-dashboards
     Host: http://superset:8088
     Username: admin
     Password: admin
     ```
   - Click **Test Connection** and then **Save**

6. **View Data Lineage:**
   - Navigate to **Explore** > **Tables**
   - Select any table from the `jaffle_shop_dev` schema
   - Click on the **Lineage** tab to see data flow and transformations
   - The lineage will show how dbt models transform raw data into final tables

7. **Connect dbt Lineage (Advanced):**
   To get full dbt lineage in OpenMetadata:
   - Configure dbt to generate `manifest.json` files
   - Use OpenMetadata's dbt integration to import model lineage
   - This will show the complete data transformation pipeline

### Superset Configuration

Superset is configured to:
- Connect to the same PostgreSQL database as dbt
- Use Redis for caching
- Access the `jaffle_shop_dev` schema where dbt models are built
- Provide a web interface for creating dashboards from dbt models

#### Setting Up Superset

After starting the stack and building dbt models, follow these steps to set up Superset:

1. **Access Superset:**
   - URL: http://localhost:8088
   - Username: `admin`
   - Password: `admin`

2. **Add Database Connection:**
   - Go to **Settings** > **Database Connections**
   - Click **+ Database**
   - Select **PostgreSQL** as the database type
   - Fill in the connection details:
     ```
     Host: postgres
     Port: 5432
     Database: jaffle_db
     Username: dbt_user
     Password: dbt_password
     ```
   - Click **Connect** and then **Finish**

   Note: This connects Superset to the PostgreSQL database where dbt stores the transformed data. Superset itself uses a separate PostgreSQL instance for its metadata.

3. **Add Datasets:**
   Navigate to **Data** > **Datasets** and add the following dbt models:
   - `jaffle_shop_dev.customers` - Customer dimension table
   - `jaffle_shop_dev.orders` - Orders fact table
   - `jaffle_shop_dev.order_items` - Order items fact table
   - `jaffle_shop_dev.products` - Product dimension table
   - `jaffle_shop_dev.locations` - Store locations

4. **Create Sample Dashboards:**
   Some dashboard ideas using the Jaffle Shop data:
   - **Sales Dashboard**: Total revenue, orders over time, top products
   - **Customer Analytics**: Customer acquisition, repeat customers, customer lifetime value
   - **Product Performance**: Best-selling products, product categories, inventory insights
   - **Store Performance**: Revenue by location, store comparisons

5. **Troubleshooting:**
   - If Superset can't connect to the database, check that PostgreSQL is running: `make postgres`
   - View Superset logs for errors: `make superset-logs`
   - Ensure dbt models are built: `make dbt-build-project`
   - If you encounter PostgreSQL driver errors, rebuild Superset: `make superset-build`

**OpenMetadata Troubleshooting:**
   - If OpenMetadata won't start, check Elasticsearch is running: `make elasticsearch`
   - View OpenMetadata logs: `make openmetadata-logs`
   - Check migration logs if database setup fails: `make openmetadata-migrate-logs`
   - Ensure PostgreSQL is accessible from OpenMetadata container
   - Check that all required ports are available (8585, 8586, 9200, 9300)
   - If migrations fail, ensure PostgreSQL is healthy before running migrations

### dbt Service

The dbt service is designed as a one-off container that runs dbt commands and exits. It's not a persistent service like PostgreSQL or Superset. Each time you run a dbt command through the Makefile, it spins up a new container, executes the command, and removes the container.

This approach ensures:
- Clean execution environment for each dbt command
- No resource consumption when not running dbt commands
- Easy integration with CI/CD pipelines
- Consistent environment across different machines
