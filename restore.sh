#!/bin/bash

# Verificar que se pasó un archivo como parámetro
if [ -z "$1" ]; then
    echo "Uso: ./restore.sh <archivo_backup.sql.gz>"
    echo "Backups disponibles:"
    ls -lh ~/boardgame-tracker/backups/
    exit 1
fi

BACKUP_FILE=$1

# Verificar que el archivo existe
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: El archivo $BACKUP_FILE no existe"
    exit 1
fi

echo "ADVERTENCIA: Esto reemplazará todos los datos actuales de la base de datos."
read -p "¿Estás seguro? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Restauración cancelada"
    exit 0
fi

echo "Descomprimiendo backup..."
gunzip -c "$BACKUP_FILE" | docker compose exec -T db psql -U bguser boardgames

echo "Restauración completada"
