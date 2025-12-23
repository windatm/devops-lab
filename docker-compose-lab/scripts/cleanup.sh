#!/bin/bash
# Script cleanup để xóa tất cả Docker Compose resources
# Xóa containers, networks, volumes và images

set -e

echo "🧹 Cleaning up Docker Compose resources..."

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMPOSE_DIR="$(dirname "$SCRIPT_DIR")"

# Change to compose directory
cd "$COMPOSE_DIR"

# Stop and remove containers, networks, volumes
echo "Stopping and removing containers, networks, and volumes..."
docker compose down -v

# Remove images built by this compose file
echo "Removing images..."
docker image rm task-manager-backend:latest 2>/dev/null || true
docker image rm docker-compose-lab-backend:latest 2>/dev/null || true

# Clean up any orphaned containers
echo "Cleaning up orphaned containers..."
docker container prune -f

# Clean up any orphaned networks (be careful with this)
echo "Checking for orphaned networks..."
docker network prune -f

echo ""
echo "✅ Cleanup completed!"
echo ""
echo "Remaining Docker resources:"
echo "Containers:"
docker ps -a | grep -E "task-|CONTAINER" || echo "  (none)"
echo ""
echo "Volumes:"
docker volume ls | grep -E "task-|VOLUME" || echo "  (none)"
echo ""
echo "Networks:"
docker network ls | grep -E "task-|NETWORK" || echo "  (none)"

