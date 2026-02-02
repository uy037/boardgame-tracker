#!/bin/bash

echo "=== LOGS DE NGINX - Últimas 50 líneas ==="
echo ""
echo "--- Access Log ---"
tail -n 50 ~/boardgame-tracker/logs/boardgame_access.log
echo ""
echo "--- Error Log ---"
tail -n 50 ~/boardgame-tracker/logs/boardgame_error.log
echo ""
echo "=== ESTADÍSTICAS ==="
echo "IPs más activas (Top 10):"
awk '{print $1}' ~/boardgame-tracker/logs/boardgame_access.log | sort | uniq -c | sort -rn | head -10
echo ""
echo "URLs más accedidas (Top 10):"
awk '{print $7}' ~/boardgame-tracker/logs/boardgame_access.log | sort | uniq -c | sort -rn | head -10
echo ""
echo "Códigos de respuesta:"
awk '{print $9}' ~/boardgame-tracker/logs/boardgame_access.log | sort | uniq -c | sort -rn
