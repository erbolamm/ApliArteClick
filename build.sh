#!/bin/bash

# ApliArte Click Pro - Build Script
# Este script ayuda a compilar la aplicación para todas las plataformas

set -e

echo "🚀 ApliArte Click Pro - Build Script v1.0.0"
echo "============================================"
echo ""

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para compilar macOS
build_macos() {
    echo -e "${BLUE}📦 Compilando para macOS...${NC}"
    flutter build macos --release
    
    echo -e "${BLUE}📦 Creando ZIP para distribución...${NC}"
    cd build/macos/Build/Products/Release
    zip -r ../../../../../ApliArteClickPro-macOS-v1.0.0.zip "ApliArte Clicker.app"
    cd ../../../../../
    
    echo -e "${GREEN}✅ macOS compilado exitosamente!${NC}"
    echo -e "   Archivo: ApliArteClickPro-macOS-v1.0.0.zip"
    ls -lh ApliArteClickPro-macOS-v1.0.0.zip
}

# Función para compilar Windows
build_windows() {
    echo -e "${BLUE}📦 Compilando para Windows...${NC}"
    flutter build windows --release
    
    echo -e "${BLUE}📦 Creando ZIP para distribución...${NC}"
    cd build/windows/runner/Release
    zip -r ../../../../ApliArteClickPro-Windows-v1.0.0.zip .
    cd ../../../../
    
    echo -e "${GREEN}✅ Windows compilado exitosamente!${NC}"
    echo -e "   Archivo: ApliArteClickPro-Windows-v1.0.0.zip"
    ls -lh ApliArteClickPro-Windows-v1.0.0.zip
}

# Función para compilar Linux
build_linux() {
    echo -e "${BLUE}📦 Compilando para Linux...${NC}"
    flutter build linux --release
    
    echo -e "${BLUE}📦 Creando tarball para distribución...${NC}"
    cd build/linux/x64/release
    tar -czf ../../../../ApliArteClickPro-Linux-v1.0.0.tar.gz bundle/
    cd ../../../../
    
    echo -e "${GREEN}✅ Linux compilado exitosamente!${NC}"
    echo -e "   Archivo: ApliArteClickPro-Linux-v1.0.0.tar.gz"
    ls -lh ApliArteClickPro-Linux-v1.0.0.tar.gz
}

# Función para compilar todas las plataformas
build_all() {
    echo -e "${YELLOW}⚠️  Compilando para TODAS las plataformas...${NC}"
    echo -e "${YELLOW}   Esto puede tardar varios minutos.${NC}"
    echo ""
    
    # Detectar sistema operativo
    OS="$(uname -s)"
    case "${OS}" in
        Linux*)     
            echo -e "${BLUE}Sistema detectado: Linux${NC}"
            build_linux
            ;;
        Darwin*)    
            echo -e "${BLUE}Sistema detectado: macOS${NC}"
            build_macos
            ;;
        MINGW*|MSYS*|CYGWIN*)     
            echo -e "${BLUE}Sistema detectado: Windows${NC}"
            build_windows
            ;;
        *)          
            echo -e "${YELLOW}⚠️  Sistema no reconocido: ${OS}${NC}"
            echo -e "${YELLOW}   Por favor, especifica la plataforma manualmente.${NC}"
            exit 1
            ;;
    esac
}

# Función para limpiar builds anteriores
clean() {
    echo -e "${BLUE}🧹 Limpiando builds anteriores...${NC}"
    flutter clean
    rm -f ApliArteClickPro-*.zip ApliArteClickPro-*.tar.gz
    echo -e "${GREEN}✅ Limpieza completada!${NC}"
}

# Función para ejecutar tests
test() {
    echo -e "${BLUE}🧪 Ejecutando tests...${NC}"
    flutter test
    echo -e "${GREEN}✅ Tests completados!${NC}"
}

# Menú principal
show_menu() {
    echo ""
    echo "Selecciona una opción:"
    echo "  1) Compilar para macOS"
    echo "  2) Compilar para Windows"
    echo "  3) Compilar para Linux"
    echo "  4) Compilar para plataforma actual"
    echo "  5) Ejecutar tests"
    echo "  6) Limpiar builds"
    echo "  7) Salir"
    echo ""
}

# Si se pasa un argumento, ejecutar directamente
if [ $# -eq 1 ]; then
    case "$1" in
        macos|mac)
            build_macos
            ;;
        windows|win)
            build_windows
            ;;
        linux)
            build_linux
            ;;
        all)
            build_all
            ;;
        clean)
            clean
            ;;
        test)
            test
            ;;
        *)
            echo -e "${YELLOW}Opción no reconocida: $1${NC}"
            echo "Uso: $0 [macos|windows|linux|all|clean|test]"
            exit 1
            ;;
    esac
else
    # Modo interactivo
    while true; do
        show_menu
        read -p "Opción: " choice
        case $choice in
            1) build_macos ;;
            2) build_windows ;;
            3) build_linux ;;
            4) build_all ;;
            5) test ;;
            6) clean ;;
            7) 
                echo -e "${GREEN}👋 ¡Hasta luego!${NC}"
                exit 0
                ;;
            *) 
                echo -e "${YELLOW}⚠️  Opción inválida${NC}"
                ;;
        esac
    done
fi

echo ""
echo -e "${GREEN}✨ ¡Proceso completado!${NC}"
