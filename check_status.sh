#!/bin/bash

echo "=== ESTADO DE CONTENEDORES ==="
docker compose ps
echo ""
echo "=== USO DE RECURSOS ==="
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
echo ""
echo "=== ESPACIO EN DISCO ==="
df -h | grep -E "Filesystem|/dev/root"
echo ""
echo "=== CERTIFICADO SSL ==="
docker compose run --rm --entrypoint "" certbot certbot certificates
