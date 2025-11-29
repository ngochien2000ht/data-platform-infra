#!/bin/bash

# Docker infrastructure stop script
# Gracefully stops all services

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Stopping Docker services...${NC}"
echo ""

# Stop services
docker compose down

echo ""
echo -e "${GREEN}✓ Services stopped${NC}"
echo ""
echo -e "${YELLOW}Note: Data is preserved in volumes/${NC}"
echo -e "${YELLOW}To remove all data, run: ${RED}docker compose down -v${NC}"
echo ""
