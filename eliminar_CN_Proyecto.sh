#!/bin/bash
echo "Iniciando eliminación completa del proyecto CN_Proyecto..."

# Variables
BACKEND_DIR="$HOME/CN_Proyecto/CN_api_bk"
FRONTEND_DIR="$HOME/CN_Proyecto/CN_React"
DB_NAME="proyecto"
DB_USER="postgres"
BACKEND_PORT=3000
FRONTEND_PORT=5173

# Detener procesos en puertos
echo "Deteniendo procesos en puertos $BACKEND_PORT y $FRONTEND_PORT..."
fuser -k $BACKEND_PORT/tcp 2>/dev/null
fuser -k $FRONTEND_PORT/tcp 2>/dev/null

# Eliminar carpetas
echo "Eliminando carpetas del proyecto..."
rm -rf "$BACKEND_DIR" "$FRONTEND_DIR"

# Eliminar base de datos
echo "Eliminando base de datos '$DB_NAME'..."
psql -U $DB_USER -c "DROP DATABASE IF EXISTS $DB_NAME;"

echo "Eliminación completada correctamente."
