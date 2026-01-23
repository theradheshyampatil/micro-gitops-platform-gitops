#!/usr/bin/env bash
set -e

echo "================ VM CLEANUP AUDIT ================"

echo ""
echo "📁 Home directory files (top level):"
ls -lh /home/ubuntu | sed 's/^/  /'

echo ""
echo "🐳 Docker images (unused candidates):"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"

echo ""
echo "🐳 Stopped containers:"
docker ps -a --filter "status=exited" --filter "status=created"

echo ""
echo "📦 Dangling Docker volumes:"
docker volume ls -f dangling=true

echo ""
echo "📦 Dangling Docker images:"
docker images -f dangling=true

echo ""
echo "📜 Phase scripts NOT in GitOps repo:"
find /home/ubuntu -maxdepth 1 -type f -name "phase*-*.sh"

echo ""
echo "☸️ Images currently used by Kubernetes:"
kubectl get pods -n apps -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}'

echo ""
echo "================ AUDIT COMPLETE =================="
