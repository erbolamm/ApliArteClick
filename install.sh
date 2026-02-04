#!/bin/bash

# ApliArte Click Pro - Instalador Remoto
# Descarga e instala la última versión disponible desde GitHub

set -e

# Configuración
REPO_OWNER="erbolamm"
REPO_NAME="ApliArteClick"
APP_NAME="ApliArte Clicker.app"
INSTALL_DIR="/Applications"
TEMP_DIR=$(mktemp -d)
VERSION="${1:-v2.0.0}" # Default to v2.0.0, or use first argument
FILENAME="ApliArteClickPro-macOS-${VERSION}.zip"
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${VERSION}/${FILENAME}"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Instalador de ApliArte Click Pro${NC}"
echo "====================================="

# Verificar SO
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}❌ Este instalador es solo para macOS.${NC}"
    exit 1
fi

echo -e "${BLUE}⬇️  Descargando versión ${VERSION}...${NC}"
echo "   URL: ${DOWNLOAD_URL}"

# Descargar
if curl -fL "${DOWNLOAD_URL}" -o "${TEMP_DIR}/${FILENAME}"; then
    echo -e "${GREEN}✅ Descarga completada.${NC}"
else
    echo -e "${RED}❌ Error al descargar. Verifica tu conexión o que la versión exista.${NC}"
    rm -rf "${TEMP_DIR}"
    exit 1
fi

# Descomprimir
echo -e "${BLUE}📦 Descomprimiendo...${NC}"
unzip -q "${TEMP_DIR}/${FILENAME}" -d "${TEMP_DIR}"

if [ ! -d "${TEMP_DIR}/${APP_NAME}" ]; then
    echo -e "${RED}❌ Error: No se encontró la aplicación en el archivo descargado.${NC}"
    rm -rf "${TEMP_DIR}"
    exit 1
fi

# Instalar
echo -e "${BLUE}📂 Instalando en ${INSTALL_DIR}...${NC}"

# Borrar versión anterior si existe
if [ -d "${INSTALL_DIR}/${APP_NAME}" ]; then
    echo -e "${YELLOW}⚠️  Eliminando versión anterior...${NC}"
    rm -rf "${INSTALL_DIR}/${APP_NAME}"
fi

# Mover nueva versión
mv "${TEMP_DIR}/${APP_NAME}" "${INSTALL_DIR}/"

# Limpiar
rm -rf "${TEMP_DIR}"

# Abrir
echo ""
echo -e "${GREEN}🎉 ¡Instalación completada con éxito!${NC}"
echo -e "   ApliArte Click Pro se ha instalado en tus Aplicaciones."
echo ""
echo -e "${BLUE}👉 Ejecutando aplicación...${NC}"
open "${INSTALL_DIR}/${APP_NAME}"
