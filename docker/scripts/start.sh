#!/bin/bash

# Docker infrastructure startup script
# Usage: ./start.sh [dev|prod]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
MODE="${1:-dev}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Data Pipeline Docker Infrastructure${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if .env exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}⚠️  .env file not found!${NC}"
    echo -e "${YELLOW}Creating .env from .env.example...${NC}"
    cp "$SCRIPT_DIR/.env.example" "$ENV_FILE"
    echo -e "${GREEN}✓ .env created${NC}"
    echo -e "${YELLOW}Please review and update .env if needed${NC}"
    echo ""
fi

# Load environment variables
export $(cat "$ENV_FILE" | grep -v '^#' | xargs)

echo -e "${GREEN}Starting services in ${YELLOW}${MODE}${GREEN} mode...${NC}"
echo ""

case "$MODE" in
    dev)
        echo "Development mode: Code mounted, extended logging"
        docker compose up -d
        ;;
    prod)
        echo "Production mode: Auto-restart, optimized settings"
        docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
        ;;
    *)
        echo -e "${RED}Invalid mode: $MODE${NC}"
        echo "Usage: ./start.sh [dev|prod]"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✓ Services started${NC}"
echo ""

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 10

# Check service status
echo ""
echo -e "${GREEN}Service Status:${NC}"
docker compose ps

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Quick Links:${NC}"
echo -e "${GREEN}========================================${NC}"
echo "Airflow Webserver: ${YELLOW}http://localhost:${AIRFLOW_WEBUI_LOCAL_PORT}${NC} (admin/admin)"
echo "Kafka UI:          ${YELLOW}http://localhost:8888${NC}"
echo "Kibana:            ${YELLOW}http://localhost:${KIBANA_LOCAL_PORT}${NC}"
echo "Grafana:           ${YELLOW}http://localhost:${GRAFANA_LOCAL_PORT}${NC} (admin/admin)"
echo "Jaeger UI:         ${YELLOW}http://localhost:${JAEGER_UI_LOCAL_PORT}${NC}"
echo "MinIO Console:     ${YELLOW}http://localhost:${MINIO_CONSOLE_LOCAL_PORT}${NC} (minioadmin/minioadmin)"
echo "Prometheus:        ${YELLOW}http://localhost:${PROMETHEUS_LOCAL_PORT}${NC}"
echo "Spark Master:      ${YELLOW}http://localhost:${SPARK_MASTER_WEBUI_LOCAL_PORT}${NC}"
echo "Spark History:     ${YELLOW}http://localhost:${SPARK_HISTORY_LOCAL_PORT}${NC}"
echo ""
echo -e "${GREEN}View logs: ${YELLOW}docker compose logs -f${NC}"
echo -e "${GREEN}Stop services: ${YELLOW}docker compose down${NC}"
echo ""
