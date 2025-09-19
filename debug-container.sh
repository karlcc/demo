#!/bin/bash

echo "=== Docker Container Debugging Script ==="
echo "Date: $(date)"
echo

echo "=== Docker Images ==="
docker images | grep demo

echo
echo "=== Running Containers ==="
docker ps

echo
echo "=== Container Logs (last 50 lines) ==="
docker compose logs --tail=50 symfony-app

echo
echo "=== Check if container is running ==="
docker compose ps

echo
echo "=== Test container access ==="
echo "Checking if we can access the container..."
docker compose exec symfony-app php --version || echo "Cannot access container"

echo
echo "=== Check Symfony console ==="
docker compose exec symfony-app php bin/console list || echo "Console access failed"

echo
echo "=== Check importmap status ==="
docker compose exec symfony-app php bin/console debug:config asset_mapper || echo "AssetMapper config failed"

echo
echo "=== Check if assets exist ==="
docker compose exec symfony-app ls -la public/assets/ || echo "No public/assets directory"

echo
echo "=== Check vendor directory ==="
docker compose exec symfony-app ls -la vendor/ | head -10

echo
echo "=== Check if importmap.php exists ==="
docker compose exec symfony-app ls -la importmap.php || echo "No importmap.php found"

echo
echo "=== Try running importmap:install manually ==="
docker compose exec symfony-app php bin/console importmap:install --no-interaction || echo "importmap:install failed"

echo
echo "=== Check Symfony environment ==="
docker compose exec symfony-app php bin/console debug:config framework.assets || echo "Assets config failed"