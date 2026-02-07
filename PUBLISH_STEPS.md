# 📋 Guía Rápida de Publicación v3.0.0

## ✅ Estado Actual

Todo está listo para publicar. Solo falta conectividad a GitHub.

**Archivos preparados:**
- ✅ ApliArteClickPro-macOS-v3.0.0.zip (57MB)
- ✅ Tag v3.0.0 creado
- ✅ Código actualizado y committed
- ✅ Scripts de instalación configurados

---

## 🚀 Pasos para Publicar (MANUAL)

### 1️⃣ Push a GitHub

Cuando tengas conexión a Internet:

```bash
cd /Users/apliarte/apps/click_mac

# Push del código
git push origin main

# Push del tag
git push origin v3.0.0
```

---

### 2️⃣ Crear Release en GitHub

**Opción A - Usando GitHub CLI (gh):**
```bash
gh release create v3.0.0 \
  ApliArteClickPro-macOS-v3.0.0.zip \
  --title "v3.0.0 - Advanced Sequence Controls" \
  --notes-file release_notes.md
```

**Opción B - Navegador (más fácil):**

1. Abre: https://github.com/erbolamm/ApliArteClick/releases/new

2. Rellena el formulario:
   - **Tag**: v3.0.0 (selecciónalo de la lista)
   - **Title**: v3.0.0 - Advanced Sequence Controls
   
3. **Description** (copia esto):
```markdown
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
```

4. **Arrastra el archivo**: `ApliArteClickPro-macOS-v3.0.0.zip`

5. Click **"Publish release"**

---

### 3️⃣ Deploy de Firebase

```bash
cd /Users/apliarte/apps/click_mac

# Reautenticar (si es necesario)
firebase login --reauth

# Desplegar
firebase deploy --only hosting
```

---

### 4️⃣ Verificar Instalación

Prueba que el instalador funciona:

```bash
# Esto debería instalar v3.0.0 automáticamente
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/erbolamm/ApliArteClick/main/install.sh)"
```

Verifica que descarga la v3.0.0 y no la v2.0.0.

---

### 5️⃣ Verificar Landing Page

Abre: https://apliarte-click-pro-2026.web.app

Verifica que:
- ✅ Badge dice "Versión 3.0 (Advanced)"
- ✅ Comando por defecto NO tiene `-- v2.0.0`
- ✅ Hay tarjeta de "Control de Flujo Avanzado"

---

## 🆘 Si algo falla

### GitHub no acepta el push:
```bash
# Verificar estado
git status
git log --oneline -3

# Si necesitas forzar (solo si estás seguro)
git push origin main --force
```

### Firebase falla en login:
```bash
# Usar CI token
firebase login:ci
# Usar el token generado
```

### El instalador descarga la versión incorrecta:
```bash
# Verificar que install.sh tiene v3.0.0
grep "VERSION=" install.sh

# Debería mostrar:
# VERSION="${1:-v3.0.0}"
```

---

## ✅ Checklist Final

Antes de dar por terminado:

- [ ] GitHub muestra el tag v3.0.0
- [ ] Release v3.0.0 visible en releases
- [ ] .zip subido al release
- [ ] Landing page actualizada
- [ ] Instalador descarga v3.0.0 por defecto
- [ ] App se ejecuta correctamente

---

## 🎉 ¡Listo!

Una vez completados todos los pasos, la v3.0.0 estará publicada y disponible para descarga.

**Comandos resumen (copiar y pegar):**
```bash
cd /Users/apliarte/apps/click_mac
git push origin main
git push origin v3.0.0
# Luego abre https://github.com/erbolamm/ApliArteClick/releases/new
firebase login --reauth
firebase deploy --only hosting
```
