# Docker Infrastructure Setup

Complete Docker Compose setup for data pipeline with Kafka, Spark, Airflow, Elasticsearch, MinIO, and monitoring tools.

## 📋 Directory Structure

```
docker/
├── docker-compose.yml                 # Main compose file (all services)
├── docker-compose.override.yml        # Development overrides
├── docker-compose.prod.yml            # Production configuration
├── .env                               # Environment variables (copy from .env.example)
├── .env.example                       # Template for environment variables
│
├── compose/                           # Individual service compose files
│   ├── kafka-cluster.yml              # Kafka + Zookeeper + Kafka UI
│   ├── schema-registry.yml            # Optional Avro/Protobuf support
│   ├── elasticsearch-kibana.yml       # Search & log visualization
│   ├── minio.yml                      # S3-compatible storage
│   ├── spark.yml                      # Spark cluster
│   ├── airflow.yml                    # Airflow orchestration
│   ├── monitoring.yml                 # Prometheus + Grafana + Jaeger
│   └── db.yml                         # PostgreSQL database
│
├── config/                            # Configuration files
│   ├── kafka/server.properties
│   ├── elasticsearch/elasticsearch.yml
│   ├── spark/spark-defaults.conf
│   ├── airflow/airflow.cfg
│   ├── prometheus/prometheus.yml
│   └── minio/create-buckets.sh
│
├── init/                              # Initialization scripts
│   ├── kafka-create-topics.sh
│   ├── elasticsearch-init-security.sh
│   └── minio-create-buckets.sh
│
└── volumes/                           # Data persistence (git ignored)
    ├── kafka/
    ├── zookeeper/
    ├── elasticsearch/
    ├── minio/
    ├── spark-history/
    ├── airflow-logs/
    └── postgres-data/
```

## 🚀 Quick Start

### 1. Setup Environment
```bash
cd infrastructure/docker

# Copy .env.example to .env (if not already done)
cp .env.example .env

# Edit .env with your custom values (optional)
nano .env
```

### 2. Start All Services
```bash
# Development mode (with code mounts and extra ports exposed)
docker compose up -d

# Or production mode
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### 3. Verify Services
```bash
docker compose ps

# Check health
docker compose ps --filter "health=healthy"
```

### 4. Access Services

| Service | URL | Default Credentials |
|---------|-----|-------------------|
| Airflow Webserver | http://localhost:8080 | admin / admin |
| Kafka UI | http://localhost:8888 | - |
| Kibana | http://localhost:5601 | - |
| Grafana | http://localhost:3000 | admin / admin |
| Jaeger UI | http://localhost:16686 | - |
| MinIO Console | http://localhost:9001 | minioadmin / minioadmin |
| Prometheus | http://localhost:9090 | - |
| Spark Master | http://localhost:8080 | - |
| Spark History | http://localhost:18080 | - |

## 🔧 Compose Files Usage

### Using Individual Service Compose Files
You can compose services selectively:

```bash
# Start only Kafka cluster
docker compose -f compose/kafka-cluster.yml up -d

# Start Kafka + MinIO + Elasticsearch
docker compose \
  -f compose/kafka-cluster.yml \
  -f compose/minio.yml \
  -f compose/elasticsearch-kibana.yml \
  up -d

# Start full stack
docker compose \
  -f compose/db.yml \
  -f compose/kafka-cluster.yml \
  -f compose/minio.yml \
  -f compose/elasticsearch-kibana.yml \
  -f compose/spark.yml \
  -f compose/airflow.yml \
  -f compose/monitoring.yml \
  up -d
```

## 📝 Environment Variables

Edit `.env` to customize:

```bash
# Database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=change_me
POSTGRES_DB=airflow_db

# Airflow
AIRFLOW__CORE__FERNET_KEY=your_fernet_key
AIRFLOW_WEBSERVER_SECRET_KEY=your_secret_key

# MinIO
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=change_me

# Monitoring
GRAFANA_ADMIN_PASSWORD=change_me
```

## 🔄 Common Commands

### Start Services
```bash
# Start all services
docker compose up -d

# Start with logs
docker compose up

# Start specific service
docker compose up -d airflow-webserver
```

### Stop Services
```bash
# Stop all services
docker compose down

# Stop and remove volumes (CAUTION: deletes data!)
docker compose down -v

# Stop specific service
docker compose stop airflow-scheduler
```

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f airflow-webserver

# Last 100 lines
docker compose logs --tail=100 kafka
```

### Execute Commands
```bash
# Bash into container
docker compose exec airflow-webserver bash

# Run Airflow CLI
docker compose exec airflow-webserver airflow dags list

# Run Kafka commands
docker compose exec kafka kafka-topics.sh --list --bootstrap-server localhost:9092
```

## 📊 Data Persistence

All data is persisted in `volumes/` directory:

- **postgres-data**: Airflow metadata & business data
- **kafka**: Kafka broker data
- **zookeeper**: Zookeeper coordination data
- **elasticsearch**: Elasticsearch indices
- **minio**: Object storage
- **spark-history**: Spark job history
- **airflow-logs**: Airflow task logs

## 🔐 Production Deployment

Use `docker-compose.prod.yml` for production:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

**Key Production Settings:**
- Auto-restart enabled for all services
- No code volume mounts
- Reduced debug settings
- Optimized memory allocation
- Security disabled for Elasticsearch (enable if needed)

### Security Checklist

- [ ] Change all default passwords in `.env`
- [ ] Generate secure FERNET_KEY for Airflow
- [ ] Generate secure SECRET_KEY for Airflow Webserver
- [ ] Enable Elasticsearch security
- [ ] Use reverse proxy (nginx) for external access
- [ ] Enable TLS/SSL for all services
- [ ] Set resource limits on containers
- [ ] Regular backup of `volumes/` directory

## 🐛 Troubleshooting

### Container Won't Start
```bash
# Check logs
docker compose logs service_name

# Restart service
docker compose restart service_name

# Rebuild image
docker compose up -d --build service_name
```

### Database Connection Issues
```bash
# Check PostgreSQL health
docker compose exec postgres pg_isready -U postgres

# Connect to PostgreSQL
docker compose exec postgres psql -U postgres -d airflow_db
```

### Kafka Issues
```bash
# Check broker health
docker compose exec kafka kafka-broker-api-versions.sh --bootstrap-server localhost:9092

# List topics
docker compose exec kafka kafka-topics.sh --list --bootstrap-server localhost:9092

# Create topic
docker compose exec kafka kafka-topics.sh --create --bootstrap-server localhost:9092 \
  --topic test-topic --partitions 1 --replication-factor 1
```

### Airflow Issues
```bash
# Check migrations
docker compose exec airflow-webserver airflow db upgrade

# Reset database
docker compose exec airflow-webserver airflow db reset

# Trigger DAG
docker compose exec airflow-webserver airflow dags trigger my_dag
```

## 📦 Memory & Resource Requirements

**Minimum Requirements:**
- CPU: 4 cores
- RAM: 8GB
- Disk: 20GB

**Recommended for Development:**
- CPU: 8 cores
- RAM: 16GB
- Disk: 50GB

**Recommended for Production:**
- CPU: 16+ cores
- RAM: 32GB+
- Disk: 100GB+

## 🔗 Service Dependencies

```
airflow-webserver
  ├── postgres (healthy)
  └── redis (healthy)

airflow-scheduler
  ├── postgres (healthy)
  ├── redis (healthy)
  └── airflow-webserver (started)

airflow-worker
  ├── postgres (healthy)
  ├── redis (healthy)
  └── airflow-webserver (started)

kafka
  └── zookeeper

spark-worker
  └── spark-master

spark-history-server
  └── spark-master

kibana
  └── elasticsearch

grafana
  └── prometheus
```

## 📚 References

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Apache Airflow Documentation](https://airflow.apache.org/)
- [Apache Kafka Documentation](https://kafka.apache.org/)
- [Apache Spark Documentation](https://spark.apache.org/)
- [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [MinIO Documentation](https://docs.min.io/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)

## 📄 License

This Docker infrastructure is part of the data pipeline project.
