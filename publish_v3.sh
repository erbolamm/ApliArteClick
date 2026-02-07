#!/bin/bash

# Script de Publicación Automática - Versión 3.0.0
# Ejecuta este script cuando tengas conexión a Internet

set -e

echo "🚀 Publicando ApliArte Click Pro v3.0.0"
echo "======================================"
echo ""

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar conexión
echo -e "${BLUE}🌐 Verificando conexión a GitHub...${NC}"
if ! ping -c 1 github.com >/dev/null 2>&1; then
    echo -e "${RED}❌ No hay conexión a GitHub${NC}"
    echo -e "${YELLOW}Por favor, verifica tu conexión a Internet y vuelve a intentarlo.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Conexión OK${NC}"
echo ""

# Paso 1: Push de los cambios
echo -e "${BLUE}📤 Paso 1/5: Haciendo push a GitHub...${NC}"
git push origin main
echo -e "${GREEN}✅ Push completado${NC}"
echo ""

# Paso 2: Push del tag
echo -e "${BLUE}🏷️  Paso 2/5: Publicando tag v3.0.0...${NC}"
git push origin v3.0.0
echo -e "${GREEN}✅ Tag publicado${NC}"
echo ""

# Paso 3: Crear release en GitHub
echo -e "${BLUE}📦 Paso 3/5: Creando release en GitHub...${NC}"
echo -e "${YELLOW}Abriendo navegador para crear el release...${NC}"
open "https://github.com/erbolamm/ApliArteClick/releases/new?tag=v3.0.0&title=v3.0.0%20-%20Advanced%20Sequence%20Controls"
echo ""
echo -e "${YELLOW}Por favor, completa estos pasos en el navegador:${NC}"
echo "1. Verifica que el tag sea: v3.0.0"
echo "2. El título debe ser: v3.0.0 - Advanced Sequence Controls"
echo "3. Copia la descripción del release (ver más abajo)"
echo "4. Arrastra el archivo: ApliArteClickPro-macOS-v3.0.0.zip"
echo "5. Click en 'Publish release'"
echo ""
echo -e "${BLUE}📝 Descripción del release:${NC}"
echo "──────────────────────────────────────────────"
cat << 'EOF'
# 🚀 Version 3.0.0 - Advanced Sequence Controls

## ✨ Nuevas Características

### 🔄 Control de Flujo Avanzado
- **Bucles (Loops)**: Agrupa acciones y repítelas N veces
- **Drag & Drop**: Arrastra acciones dentro de bucles para anidarlas
- **Reordenamiento**: Usa el icono ☰ para reorganizar acciones anidadas
- **Stop Action**: Detén la ejecución en puntos específicos
- **Pause Action**: Pausas personalizadas en tu flujo

### ⌨️ Mejoras en Atajos de Teclado
- **Visualización Correcta**: Ahora muestra "Alt + B" en lugar de solo "B"
- **Guía Paso a Paso**: Instrucciones claras en el info screen

### 🎨 Mejoras de UI
- **Info Screen Premium**: Guía visual con emojis y ejemplos
- **Botón Email**: Feedback directo a info@apliarte.com
- **Timer Editor Responsive**: Los campos se actualizan mientras escribes
- **Espaciado Mejorado**: UI más limpia y profesional

## 📥 Instalación

### macOS

**Instalación automática (recomendada):**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/erbolamm/ApliArteClick/main/install.sh)"
```

**Descarga manual:**
Descarga el archivo .zip de abajo y muévelo a Aplicaciones.

## 🔄 Actualización desde v2.0

Todas las secuencias guardadas son compatibles. Simplemente instala la nueva versión.

## 🎯 Mejoras sobre v2.0

| Feature | v2.0 | v3.0 |
|---------|------|------|
| Bucles | ❌ | ✅ |
| Stop/Pause | ❌ | ✅ |
| Reordenar Anidados | ❌ | ✅ |
| Modificadores Visibles | ❌ | ✅ |
| Info Premium | ❌ | ✅ |

## 📖 Documentación

- **Web**: https://apliarte-click-pro-2026.web.app
- **README**: https://github.com/erbolamm/ApliArteClick
EOF
echo "──────────────────────────────────────────────"
echo ""
read -p "Presiona Enter cuando hayas completado el release en GitHub..."
echo -e "${GREEN}✅ Release creado${NC}"
echo ""

# Paso 4: Deploy de Firebase
echo -e "${BLUE}🔥 Paso 4/5: Desplegando landing page a Firebase...${NC}"
echo -e "${YELLOW}Verificando autenticación de Firebase...${NC}"

# Verificar si Firebase está autenticado
if ! firebase projects:list >/dev/null 2>&1; then
    echo -e "${YELLOW}Necesitas reautenticarte en Firebase...${NC}"
    firebase login --reauth
fi

echo -e "${BLUE}Desplegando landing page...${NC}"
firebase deploy --only hosting
echo -e "${GREEN}✅ Landing page desplegada${NC}"
echo ""

# Paso 5: Verificación
echo -e "${BLUE}✅ Paso 5/5: Verificación final...${NC}"
echo ""
echo -e "${GREEN}Verificando que todo funcione:${NC}"
echo ""
echo "1. Probando script de instalación..."
echo "   (Esto instalará la v3.0.0 en tu Mac)"
read -p "   ¿Quieres probar la instalación ahora? (s/n): " test_install

if [[ "$test_install" == "s" ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/erbolamm/ApliArteClick/main/install.sh)"
fi

echo ""
echo "2. Abriendo landing page..."
open "https://apliarte-click-pro-2026.web.app"

echo ""
echo -e "${GREEN}🎉 ¡Publicación completada con éxito!${NC}"
echo ""
echo -e "${BLUE}Resumen:${NC}"
echo "  ✅ Código subido a GitHub"
echo "  ✅ Tag v3.0.0 publicado"
echo "  ✅ Release creado en GitHub"
echo "  ✅ Landing page actualizada"
echo "  ✅ Script de instalación actualizado"
echo ""
echo -e "${GREEN}La versión 3.0.0 está ahora disponible para descarga! 🚀${NC}"
