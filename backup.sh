#!/bin/bash

# Configuración
BACKUP_DIR=~/boardgame-tracker/backups
COMPOSE_DIR=~/boardgame-tracker
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="boardgame_backup_${DATE}.sql"
DAYS_TO_KEEP=7

# Cambiar al directorio del proyecto
cd "$COMPOSE_DIR" || exit 1

# Crear backup
echo "Creando backup de la base de datos..."
/usr/bin/docker compose exec -T db pg_dump -U bguser boardgames > "${BACKUP_DIR}/${BACKUP_FILE}"

# Verificar que el backup se creó correctamente
if [ ! -s "${BACKUP_DIR}/${BACKUP_FILE}" ]; then
    echo "ERROR: El backup falló o está vacío"
    rm -f "${BACKUP_DIR}/${BACKUP_FILE}"
    exit 1
fi

# Comprimir backup
echo "Comprimiendo backup..."
gzip "${BACKUP_DIR}/${BACKUP_FILE}"

# Eliminar backups antiguos
echo "Eliminando backups antiguos (más de ${DAYS_TO_KEEP} días)..."
find "${BACKUP_DIR}" -name "boardgame_backup_*.sql.gz" -mtime +${DAYS_TO_KEEP} -delete

echo "Backup completado: ${BACKUP_FILE}.gz"
echo "Tamaño: $(ls -lh ${BACKUP_DIR}/${BACKUP_FILE}.gz | awk '{print $5}')"
echo "Backups disponibles:"
ls -lh "${BACKUP_DIR}"
