# 📦 Guía de Distribución - ApliArte Click Pro

## 🎯 Resumen Rápido

**✅ macOS**: LISTO - Archivo creado y disponible  
**⏳ Windows**: Necesita compilarse en Windows  
**⏳ Linux**: Necesita compilarse en Linux

---

## 📥 Archivo Listo para Descargar

### macOS v1.0.0
**Archivo**: `ApliArteClickPro-macOS-v1.0.0.zip`  
**Tamaño**: 52 MB  
**Ubicación**: `/Users/apliarte/apps/click_mac/ApliArteClickPro-macOS-v1.0.0.zip`

**Instrucciones para el usuario**:
1. Descargar el archivo ZIP
2. Descomprimir haciendo doble clic
3. Arrastrar "ApliArte Clicker.app" a la carpeta Aplicaciones
4. Al abrir por primera vez, ir a **Ajustes del Sistema > Privacidad y Seguridad > Accesibilidad**
5. Añadir ApliArte Click Pro a la lista de apps permitidas

---

## 🔨 Compilar para Otras Plataformas

### Opción 1: Usar el Script Automático

```bash
# Para compilar en la plataforma actual
./build.sh all

# O específicamente:
./build.sh macos    # Para macOS
./build.sh windows  # Para Windows
./build.sh linux    # Para Linux
```

### Opción 2: Comandos Manuales

#### Windows
```bash
# En una máquina Windows:
flutter build windows --release
cd build/windows/runner/Release
# Comprimir todo el contenido de esta carpeta como ZIP
```

#### Linux
```bash
# En una máquina Linux:
flutter build linux --release
cd build/linux/x64/release
tar -czf ApliArteClickPro-Linux-v1.0.0.tar.gz bundle/
```

---

## 🌐 Publicar en GitHub

### 1. Crear el Release

```bash
# Asegúrate de estar en el repositorio
cd /Users/apliarte/apps/click_mac

# Crear tag
git tag -a v1.0.0 -m "ApliArte Click Pro v1.0.0 - Primera versión oficial"

# Subir tag
git push origin v1.0.0
```

### 2. Ir a GitHub

1. Ve a tu repositorio en GitHub
2. Click en "Releases" → "Create a new release"
3. Selecciona el tag `v1.0.0`
4. Título: **ApliArte Click Pro v1.0.0**
5. Descripción:

```markdown
# 🎉 ApliArte Click Pro v1.0.0

Auto-clicker profesional multiplataforma con interfaz moderna y funciones avanzadas.

## ✨ Características Principales

- 🖱️ **Clicks Automáticos**: Precisos en coordenadas específicas
- ⌨️ **Acciones de Teclado**: Con modificadores completos
- 🎯 **Modo Dodge**: La ventana se aparta automáticamente
- 🎨 **Interfaz Premium**: Glassmorphism y animaciones suaves
- ⚡ **Atajos Globales**: F1-F12 personalizables
- ⏱️ **Temporizador Preciso**: Hasta milisegundos

## 📥 Descargas

Elige tu plataforma:

### macOS (10.14 o superior)
- Requiere permisos de Accesibilidad
- Tamaño: 52 MB

### Windows (10 o superior)
- No requiere instalación
- Ejecutable portable

### Linux (Ubuntu 20.04+)
- Compatible con Debian, Fedora, etc.
- Requiere GTK 3.0+

## 📖 Instalación

### macOS
1. Descargar el ZIP
2. Descomprimir y mover a Aplicaciones
3. Conceder permisos de Accesibilidad en Ajustes del Sistema

### Windows
1. Descargar el ZIP
2. Descomprimir en cualquier carpeta
3. Ejecutar `apliarte_click.exe`

### Linux
1. Descargar el tarball
2. Extraer: `tar -xzf ApliArteClickPro-Linux-v1.0.0.tar.gz`
3. Ejecutar: `./bundle/apliarte_click`

## 🔗 Enlaces

- 🌐 **Web**: [apliarte.com](https://apliarte.com)
- 📱 **Más Apps**: [Apps para ti](https://www.apliarte.com/p/apps-para-ti.html)
- 💬 **Soporte**: [apliarte.com/soporte](https://apliarte.com/soporte)
- ⭐ **GitHub**: [Dale una estrella](https://github.com/apliarte/click_mac)

---

**Desarrollado con ❤️ por ApliArte**
```

### 3. Subir Archivos

Arrastra y suelta estos archivos en la sección de "Assets":
- `ApliArteClickPro-macOS-v1.0.0.zip` (ya disponible)
- `ApliArteClickPro-Windows-v1.0.0.zip` (cuando esté compilado)
- `ApliArteClickPro-Linux-v1.0.0.tar.gz` (cuando esté compilado)

### 4. Publicar

Click en "Publish release" y ¡listo!

---

## 📢 Promoción

### En tu Web (apliarte.com)

Añade una sección en tu página de apps:

```html
<div class="app-card">
  <img src="logo.png" alt="ApliArte Click Pro">
  <h3>ApliArte Click Pro</h3>
  <p>Auto-clicker profesional multiplataforma</p>
  <div class="downloads">
    <a href="[enlace-github-macos]" class="btn">macOS</a>
    <a href="[enlace-github-windows]" class="btn">Windows</a>
    <a href="[enlace-github-linux]" class="btn">Linux</a>
  </div>
</div>
```

### En Redes Sociales

**Twitter/X**:
```
🎉 ¡ApliArte Click Pro v1.0.0 ya está aquí!

Auto-clicker profesional con:
🖱️ Clicks precisos
⌨️ Acciones de teclado
🎯 Modo Dodge inteligente
🎨 Interfaz premium

📥 Descarga gratis para macOS, Windows y Linux
🔗 [enlace]

#AutoClicker #Productividad #ApliArte
```

**LinkedIn**:
```
Presentando ApliArte Click Pro v1.0.0 🚀

Una herramienta de automatización profesional multiplataforma con:

✨ Interfaz moderna con glassmorphism
⚡ Atajos globales personalizables
🎯 Modo Dodge inteligente que aparta la ventana automáticamente
⏱️ Temporizador de alta precisión

Disponible para macOS, Windows y Linux.
Descarga gratuita en: [enlace]

#Automatización #Productividad #DesarrolloSoftware
```

---

## 📊 Métricas a Seguir

Una vez publicado, monitorea:
- ⬇️ Número de descargas por plataforma
- ⭐ Estrellas en GitHub
- 🐛 Issues reportados
- 💬 Comentarios de usuarios
- 🔄 Solicitudes de características

---

## 🔄 Actualizaciones Futuras

Para publicar una nueva versión:

1. Actualizar `pubspec.yaml`:
   ```yaml
   version: 1.1.0+2
   ```

2. Compilar para todas las plataformas

3. Crear nuevo release en GitHub con tag `v1.1.0`

4. Documentar cambios en el changelog

---

## ✅ Checklist de Publicación

- [x] Código compilado para macOS
- [x] Archivo ZIP creado
- [x] README actualizado
- [x] Iconos configurados
- [x] Tests pasando
- [ ] Compilar para Windows
- [ ] Compilar para Linux
- [ ] Crear GitHub Release
- [ ] Subir archivos
- [ ] Actualizar web
- [ ] Anunciar en redes sociales

---

## 🎉 ¡Listo para Compartir!

El archivo de macOS está listo en:
```
/Users/apliarte/apps/click_mac/ApliArteClickPro-macOS-v1.0.0.zip
```

Puedes:
1. Subirlo a GitHub Releases
2. Compartirlo directamente con usuarios
3. Alojarlo en tu servidor web
4. Distribuirlo como quieras

**¡Felicidades por tu primera versión oficial!** 🎊
