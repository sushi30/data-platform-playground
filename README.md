# OpenMetadata Demo

This project demonstrates integration between OpenMetadata and dbt using the Jaffle Shop example project.

## Setup

### Prerequisites

- Docker and Docker Compose
- Make (optional, for using Makefile commands)

### Quick Start

1. **Deploy the docker stack**
   ```bash
   make stack-up
   ```
   
   This will deploy the following components:
   1. **PostgreSQL** → Raw data storage
   2. **dbt** → Data transformation and modeling  
   3. **Kafka** → Real-time lineage event streaming (via OpenLineage)
   4. **Superset** → Business intelligence and dashboards
   5. **OpenMetadata** → Data catalog, lineage, and governance

2. **Run DBT trasnformations**
   ```bash
   make dbt-seed dbt-build
   ```

3. Go to the [kafka UI](http://localhost:9021/ui/clusters/openlineage/all-topics/openlineage.events/messages?keySerde=String&valueSerde=String&limit=100) to see the events.

#### Setting Up OpenMetadata

After starting the stack, follow these steps to configure OpenMetadata:

1. **Access OpenMetadata:**
   - URL: http://localhost:8585
   - Username: `admin@open-metadata.org`
   - Password: `admin`

2. **Add PostgreSQL Database Connection:**
   - Go to **Settings** > **Services** > **Databases** or [this link](http://localhost:8585/databaseServices/add-service)
   - Click **Add New Service**
   - Select **PostgreSQL** as the database type
   - Fill in the connection details:
     ```
     Service Name: postgres-jaffle-shop
     Username: dbt_user
     Password: dbt_password
     HostPort: postgres:5432
     Database: jaffle_db
     ```
   - Click **Test Connection** and then **Save**

   **Note**: We connect to the `jaffle_db` database using `dbt_user` credentials because this is where dbt creates the transformed data models that we want to catalog in OpenMetadata.

   Wait a few minutes for the database to be loaded into OpenMetadata,

3. **Configure OpenLineage Connector:**
   - Go to **Settings** > **Services** > **Pipelines** or [this link](http://localhost:8585/pipelineServices/add-service)
   - Click **Add New Service** 
   - Select **OpenLineage** as the service type
   - Fill in the connection details:
     ```
     Service Name: dbt-openlineage-kafka
     Kafka Brokers: kafka:29092
     Topic: openlineage.events
     Consumer Group: start
     ```
   - Click **Test Connection** and then **Save**. 
   - After saving, edit the pipeline and set:
      ```
      DB Service Names: postgres-jaffle-shop
      ```
   - Change the consumer group to `openmetadata-lineage-consumer` and click **Save**.

   Wait a few minutes for the OpenLineage service to start consuming events from Kafka.

4. **Ingest lineage via DBT***
   1. Repeat step (2) but name the service `dbt-jaffle-shop-dbt-lineage` and use the same PostgreSQL connection details.
   2. Go to **Settings** > **Services** > **Databases** > `dbt-jaffle-shop-dbt-lineage` >> **agents** or [this link](http://localhost:8585/service/databaseServices/postgres-jaffle-shop-dbt/agents/metadata?currentPage=1)
   3. Click **Add Agent** > **Add dbt Agent**
   4. Fill in the details:
      ```
      DBT Configuration Source: DBT Local Config
      DBT Manifest File Path: /dbt/artifacts/manifest.json
      DBT Run Results File Path: /dbt/artifacts/run_results.json
      ```
   5. Click **Next**.
   6. Click **Add & Deploy**.
   7. Run the agent from the agent page by clicking the **Overflow** button and then **Run**.

   Wait a few minutes for the dbt agent to process the manifest and run results files, which will populate the dbt models and lineage in OpenMetadata.
   
5. **Add Superset Dashboard Service:**
   - Go to **Settings** > **Services** > **Dashboard** (or [this link](http://localhost:8585/dashboardServices/add-service))
   - Click **Add New Service**
   - Select **Superset** as the dashboard type
   - Fill in the connection details:
     ```
     Service Name: superset-dashboards
     Provider: db
     Username: admin
     Password: admin
     ```
   - Click **Test Connection** and then **Save**


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
   - **OpenMetadata**: http://localhost:8585 (admin@open-metadata.org/admin)
   - **Kafka UI**: http://localhost:9021
   - **Airflow**: http://localhost:8080 (admin/admin)

5. **Set up data connections in both services as described in their respective configuration sections**

### Data Pipeline Overview

This setup creates a complete modern data stack with real-time lineage:

1. **PostgreSQL** → Raw data storage
2. **dbt** → Data transformation and modeling  
3. **Kafka** → Real-time lineage event streaming (via OpenLineage)
4. **Superset** → Business intelligence and dashboards
5. **OpenMetadata** → Data catalog, lineage, and governance

The pipeline flow: Raw Data → dbt Transformations → Analytics Tables → Superset Dashboards + OpenMetadata Real-time Lineage (via Kafka)

### OpenMetadata Configuration

OpenMetadata provides data catalog, lineage tracking, and data governance capabilities. Here's how to set it up:


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
