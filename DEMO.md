# OpenMetadata + dbt + OpenLineage Demo

This demo showcases a complete modern data stack with real-time lineage tracking from a fresh deployment to a fully functional system.

## Demo Overview

**What we'll demonstrate:**
1. 🚀 **Fresh Stack Deployment** - Start from zero to full stack in minutes
2. 📊 **Data Pipeline Execution** - Run dbt transformations with real-time lineage capture
3. 🔍 **OpenMetadata Integration** - Automatic database discovery and lineage visualization
4. 📈 **End-to-End Data Flow** - From raw data to analytics with complete observability

**Technologies showcased:**
- **dbt** - Data transformation and modeling
- **OpenLineage** - Real-time lineage capture via Kafka
- **OpenMetadata** - Data catalog and lineage visualization
- **Kafka** - Event streaming for lineage data
- **PostgreSQL** - Data warehouse
- **Apache Superset** - Business intelligence dashboards

## Demo Script

### Phase 1: Fresh Deployment (5 minutes)

#### Step 1.1: Start from Clean Slate
```bash
# Ensure clean environment
docker compose down -v
docker system prune -f

# Verify we're starting fresh
docker ps -a
```

**Demo Point**: Show that we're starting with no containers or data.

#### Step 1.2: Deploy Complete Stack
```bash
# Start the entire modern data stack
make stack-up
```

**What's happening behind the scenes:**
- ✅ PostgreSQL database with jaffle_db schema
- ✅ Kafka ecosystem (Zookeeper + Broker + UI)
- ✅ OpenMetadata server with Elasticsearch
- ✅ Apache Superset for dashboards
- ✅ OpenLineage topic creation in Kafka

**Demo Point**: Show docker compose services starting and explain the architecture.

#### Step 1.3: Verify Stack Health
```bash
# Check all services are running
docker compose ps

# Verify Kafka is ready
docker exec kafka kafka-topics --bootstrap-server kafka:29092 --list

# Check OpenMetadata API
curl -s http://localhost:8585/api/v1/system/version
```

**Demo Point**: All services are healthy and communicating.

### Phase 2: Data Pipeline with Real-time Lineage (10 minutes)

#### Step 2.1: Load Sample Data
```bash
# Seed the database with Jaffle Shop sample data
make dbt-seed
```

**What's happening:**
- Raw customer data loaded into `raw_customers` table
- Raw order data loaded into `raw_orders` table
- Raw product data loaded into `raw_products` table
- Sample store locations and order items

**Demo Point**: Show the raw tables in PostgreSQL - this is our starting point.

#### Step 2.2: Run dbt Transformations with OpenLineage
```bash
# Run dbt transformations with real-time lineage capture
docker compose run --rm dbt dbt-ol run
```

**What's happening:**
- dbt transforms raw data into staging models
- Staging models are transformed into mart models
- **OpenLineage events are sent to Kafka in real-time**
- Each transformation step is captured with full lineage metadata

**Demo Point**: Show the dbt output and explain the transformation stages.

#### Step 2.3: Verify Lineage Events in Kafka
```bash
# Check OpenLineage events were captured
docker exec kafka kafka-console-consumer \
  --bootstrap-server kafka:29092 \
  --topic openlineage.events \
  --from-beginning --timeout-ms 5000 | jq '.eventType'
```

**Demo Point**: Show real lineage events in Kafka - this is the magic happening behind the scenes.

#### Step 2.4: Run dbt Tests
```bash
# Run data quality tests
docker compose run --rm dbt dbt-ol test
```

**What's happening:**
- Data quality tests validate transformation results
- Test results are also captured in OpenLineage events
- Quality metrics are available for lineage tracking

### Phase 3: OpenMetadata Discovery and Lineage (10 minutes)

#### Step 3.1: Access OpenMetadata
```bash
# Open OpenMetadata UI
open http://localhost:8585
```

**Credentials**: admin / admin

**Demo Point**: Show the clean OpenMetadata interface - no data yet.

#### Step 3.2: Configure PostgreSQL Connection
Navigate to: **Settings > Services > Databases**

1. **Add New Service**
2. **Select PostgreSQL**
3. **Configure Connection:**
   ```
   Service Name: postgres-jaffle-shop
   Host: postgres
   Port: 5432
   Database: jaffle_db
   Username: dbt_user
   Password: dbt_password
   ```
4. **Test Connection & Save**

**Demo Point**: Show how OpenMetadata can discover database schemas.

#### Step 3.3: Configure OpenLineage Connector
Navigate to: **Settings > Services > Pipeline Services**

1. **Add New Service**
2. **Select OpenLineage**
3. **Configure Kafka Connection:**
   ```
   Service Name: dbt-openlineage-kafka
   Kafka Brokers: kafka:29092
   Topic: openlineage.events
   Consumer Group: openmetadata-lineage-consumer
   ```
4. **Test Connection & Save**

**Demo Point**: This connects OpenMetadata to our real-time lineage stream.

#### Step 3.4: Run Database Ingestion
1. **Go to PostgreSQL service**
2. **Add Ingestion > Metadata Ingestion**
3. **Configure:**
   ```
   Name: postgres-jaffle-shop-metadata
   Schema Filter: jaffle_shop_dev
   ```
4. **Deploy and Run**

**Demo Point**: Watch OpenMetadata discover all our dbt models automatically.

#### Step 3.5: Explore Discovered Assets
Navigate to: **Explore > Tables**

**Show discovered tables:**
- `jaffle_shop_dev.customers` - Customer dimension
- `jaffle_shop_dev.orders` - Orders fact table  
- `jaffle_shop_dev.order_items` - Order items
- `jaffle_shop_dev.products` - Product dimension
- `jaffle_shop_dev.locations` - Store locations

**Demo Point**: All our dbt models are now cataloged with metadata.

### Phase 4: Real-time Lineage Visualization (10 minutes)

#### Step 4.1: View Data Lineage
1. **Select any table** (e.g., `customers`)
2. **Click on Lineage tab**
3. **Explore the lineage graph**

**What you'll see:**
- `raw_customers` → `stg_customers` → `customers`
- Complete transformation pipeline
- Column-level lineage where available
- SQL transformation code

**Demo Point**: This lineage was captured automatically via OpenLineage + Kafka.

#### Step 4.2: Generate New Lineage in Real-time
```bash
# Run a specific model to generate fresh lineage
docker compose run --rm dbt dbt-ol run --select customers

# Refresh the OpenMetadata lineage view
```

**Demo Point**: Show how lineage updates in real-time as we run dbt commands.

#### Step 4.3: Explore Complex Lineage
```bash
# Run a model with multiple dependencies
docker compose run --rm dbt dbt-ol run --select order_items
```

**Navigate to `order_items` in OpenMetadata:**
- Shows dependencies on `orders`, `products`, and `raw_order_items`
- Multi-table join lineage
- Complex transformation tracking

**Demo Point**: Even complex multi-table transformations are tracked automatically.

### Phase 5: Business Intelligence Integration (5 minutes)

#### Step 5.1: Access Superset
```bash
# Open Superset UI
open http://localhost:8088
```

**Credentials**: admin / admin

#### Step 5.2: Connect to Transformed Data
1. **Settings > Database Connections**
2. **Add PostgreSQL database:**
   ```
   Host: postgres
   Database: jaffle_db
   Username: dbt_user
   Password: dbt_password
   ```

#### Step 5.3: Create Sample Dashboard
1. **Add datasets from `jaffle_shop_dev` schema**
2. **Create simple charts:**
   - Revenue over time from `orders` table
   - Customer count from `customers` table
   - Product performance from `order_items`

**Demo Point**: Show how business users consume the transformed data while data engineers track lineage.

### Phase 6: Monitoring and Observability (5 minutes)

#### Step 6.1: Kafka UI Monitoring
```bash
# Open Kafka UI
open http://localhost:9021
```

**Show:**
- `openlineage.events` topic
- Real-time message flow
- Consumer groups (OpenMetadata consuming)

#### Step 6.2: OpenMetadata Data Quality
**Navigate back to OpenMetadata:**
1. **View test results** from dbt tests
2. **Check data profiling** on tables
3. **Review lineage freshness**

#### Step 6.3: End-to-End Health Check
```bash
# Verify complete pipeline health
make stack-health  # If available, or manual checks

# Check all services
docker compose ps

# Verify data pipeline
docker compose run --rm dbt dbt-ol run --select stg_customers
```

## Demo Key Messages

### 🎯 **Value Propositions Demonstrated**

1. **Zero-Configuration Lineage**: No manual mapping - lineage flows automatically from dbt to OpenMetadata via Kafka
2. **Real-time Observability**: See data transformations and lineage as they happen
3. **Complete Data Stack**: From raw data to business intelligence with full governance
4. **Industry Standards**: Using best-of-breed open source tools (dbt, Kafka, OpenMetadata)
5. **Scalable Architecture**: Kafka enables enterprise-scale lineage processing

### 📊 **Technical Achievements Shown**

- ✅ **Automated Lineage Capture** via OpenLineage + Kafka
- ✅ **Real-time Event Streaming** for immediate lineage updates  
- ✅ **Cross-System Integration** between dbt, Kafka, and OpenMetadata
- ✅ **Complete Data Discovery** from database to business intelligence
- ✅ **Data Quality Integration** with test results in lineage
- ✅ **Column-level Lineage** for detailed transformation tracking

### 🚀 **Business Impact Highlighted**

- **Data Engineers**: Automatic lineage documentation saves hours of manual work
- **Data Analysts**: Clear data provenance builds trust in analytics
- **Compliance Teams**: Complete audit trail for regulatory requirements  
- **Business Users**: Transparent data flow from source to dashboard
- **Data Platform Teams**: Centralized governance and observability

## Demo Variations

### Quick Demo (15 minutes)
- Focus on stack deployment and basic lineage
- Skip Superset setup and complex lineage examples
- Emphasize real-time OpenLineage events

### Technical Deep Dive (45 minutes)
- Show Kafka event schemas and OpenLineage specifications
- Demonstrate column-level lineage capabilities
- Create custom dbt models during the demo
- Show advanced OpenMetadata features

### Business-Focused Demo (20 minutes)
- Emphasize governance and compliance benefits
- Focus on business user experience in OpenMetadata
- Show dashboard integration and business value
- Highlight cost savings from automated documentation

## Troubleshooting

### Common Issues During Demo

**Services won't start:**
```bash
# Check ports and resources
docker system prune -f
make stack-down && make stack-up
```

**OpenLineage events not appearing:**
```bash
# Verify Kafka connectivity from dbt
docker compose run --rm dbt python -c "
import socket
sock = socket.socket()
result = sock.connect_ex(('kafka', 29092))
print('Kafka reachable!' if result == 0 else 'Kafka unreachable')
"
```

**OpenMetadata not discovering tables:**
- Check PostgreSQL connection in UI
- Verify dbt models exist: `docker exec postgres psql -U dbt_user -d jaffle_db -c "\dt jaffle_shop_dev.*"`
- Re-run ingestion pipeline

**Lineage not showing in OpenMetadata:**
- Verify OpenLineage connector is configured and running
- Check Kafka topic has events: `docker exec kafka kafka-topics --bootstrap-server kafka:29092 --describe --topic openlineage.events`
- Ensure consumer group is active

## Demo Environment Setup

### Hardware Requirements
- **RAM**: 8GB minimum, 16GB recommended
- **CPU**: 4 cores minimum
- **Disk**: 10GB free space
- **Network**: Internet connection for Docker images

### Software Prerequisites
- Docker Desktop or Docker Engine
- Docker Compose
- Make (optional but recommended)
- Web browser
- Terminal/Command line

### Pre-Demo Checklist
- [ ] All Docker images pulled: `docker compose pull`
- [ ] No conflicting services on ports 5432, 8080, 8088, 8585, 9021, 9092
- [ ] OpenMetadata UI accessible at http://localhost:8585
- [ ] Sample queries ready for PostgreSQL validation
- [ ] Backup plan if live demo fails (recorded demo or screenshots)

---

*This demo showcases a production-ready data platform with automated lineage tracking, demonstrating how modern data teams can achieve complete data observability with minimal configuration.*
