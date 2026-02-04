# ApliArte Click Pro 🎯🖱️

Un auto-clicker profesional multiplataforma con interfaz moderna y funciones avanzadas.

**Web Oficial**: [apliarte-click-pro-2026.web.app](https://apliarte-click-pro-2026.web.app)

![ApliArte Click Logo](landing_page/assets/images/logo.svg)

## 🌟 Características Principales

### 🎯 Acciones Versátiles
- **Clicks de Ratón**: Clicks automáticos en coordenadas específicas
- **Acciones de Teclado**: Simula pulsaciones de teclas y combinaciones
- **Modificadores**: Soporte completo para Ctrl, Shift, Alt, Cmd
- **Presets Rápidos**: Alt+Tab/Cmd+Tab preconfigurado

### 🎨 Interfaz Premium
- **Diseño Moderno**: Glassmorphism, gradientes y animaciones suaves
- **Modo Oscuro**: Interfaz elegante que cuida tus ojos
- **Pantalla de Bienvenida**: Introducción profesional a la aplicación
- **HUD en Tiempo Real**: Información visual durante la grabación

### 🔧 Funciones Avanzadas
- **Modo Dodge**: La ventana se aparta automáticamente del cursor durante la grabación para no estorbar.
- **Grabación Inteligente**: Haz clic en cualquier lugar de la pantalla para capturar la posición exacta automáticamente.
- **Atajos Globales**: Tecla personalizable (F1-F12) para control rápido a nivel de sistema.

## 📥 Descargas

### macOS
- **Requisitos**: macOS 10.14 o superior
- **Descarga**: [ApliArteClickPro-macOS-v1.0.0.zip](https://github.com/erbolamm/ApliArteClick/releases/download/v1.0.0/ApliArteClickPro-macOS-v1.0.0.zip)
- **Permisos**: Requiere acceso de Accesibilidad (se solicita automáticamente)

### Windows
- **Requisitos**: Windows 10 o superior
- **Descarga**: [ApliArteClickPro.exe](#)
- **Instalación**: Ejecutable portable, no requiere instalación

### Linux
- **Requisitos**: Ubuntu 20.04+ / Debian 11+ / Fedora 35+
- **Descarga**: [apliarte-click-pro.AppImage](#)
- **Ejecución**: `chmod +x apliarte-click-pro.AppImage && ./apliarte-click-pro.AppImage`

## 🚀 Instalación

### macOS
1. Descarga el archivo `.app.zip`
2. Descomprímelo y muévelo a **Aplicaciones**
3. Al abrir por primera vez, ve a **Ajustes del Sistema > Privacidad y Seguridad > Accesibilidad**
4. Añade ApliArte Click Pro a la lista de apps permitidas

### Windows
1. Descarga el ejecutable `.exe`
2. Ejecútalo directamente (portable, sin instalación)
3. Windows Defender puede pedir confirmación (es normal para herramientas de automatización)

### Linux
1. Descarga el `.AppImage`
2. Dale permisos de ejecución: `chmod +x apliarte-click-pro.AppImage`
3. Ejecútalo: `./apliarte-click-pro.AppImage`

### 🖥️ Instalación Rápida (Terminal)
Si eres desarrollador o te gusta la terminal, hemos creado una forma **súper sencilla** de instalar la app. Simplemente copia y pega el siguiente comando en tu terminal de macOS:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/erbolamm/ApliArteClick/main/install.sh)"
```

**¿Qué hace este comando?**
1.  Descarga automáticamente la última versión segura desde GitHub Releases.
2.  Instala la aplicación en tu carpeta de `/Applications`.
3.  ¡Y listo! Ya puedes buscar "ApliArte Click Pro" en tu Launchpad.

---

## 🚀 Próximamente (Roadmap)

Estamos trabajando duro en la **versión 2.0** que incluirá una funcionalidad revolucionaria:

### ✨ Modo Multi-Clip (En Desarrollo)
Actualmente, la app permite un punto de acción. Pero estamos desarrollando un sistema para:
- **Múltiples Punteros**: Configura varios puntos de clic en diferentes partes de la pantalla.
- **Configuraciones Distintas**: Asigna intervalos y acciones diferentes a cada puntero.
- **Secuencias Complejas**: Crea automatizaciones avanzadas combinando múltiples clics y teclas.

¡Mantente atento a las actualizaciones!

## 🎮 Uso Rápido

1. **Selecciona el tipo de acción**: Mouse o Teclado.
2. **Para Mouse**: Haz clic en "GRABAR POSICIÓN", mueve el cursor a donde quieras y haz un **CLIC** normal para guardar.
3. **Para Teclado**: Selecciona la tecla y los modificadores que quieras.
4. **Configura el intervalo**: Ajusta el tiempo entre acciones
5. **Asigna un atajo**: Elige tu tecla de control (F1-F12)
6. **¡Listo!**: Pulsa INICIAR o usa tu atajo global

## 🛠️ Desarrollo

### Requisitos
- Flutter 3.10.7+
- Dart SDK 3.10.7+
- Para macOS: Xcode 14+
- Para Windows: Visual Studio 2022 con C++ tools
- Para Linux: GTK 3.0+

### Compilar desde el código
```bash
# Clonar el repositorio
git clone https://github.com/erbolamm/ApliArteClick.git
cd ApliArteClick

# Instalar dependencias
flutter pub get

# Ejecutar en modo desarrollo
flutter run -d macos  # o windows, linux

# Compilar para producción
flutter build macos --release
flutter build windows --release
flutter build linux --release
```

## 🔐 Permisos y Seguridad

### macOS
- **Accesibilidad**: Necesario para simular clicks y teclas
- **Concedido en**: Ajustes del Sistema > Privacidad y Seguridad

### Windows
- No requiere permisos especiales del sistema
- Puede activar Windows Defender (falso positivo común en herramientas de automatización)

### Linux
- Requiere acceso a X11 o Wayland para eventos de entrada
- Puede necesitar permisos de usuario para `/dev/input`

## 📝 Licencia

© 2026 ApliArte. Todos los derechos reservados.

## 🌐 Enlaces

- **Web**: [apliarte-click-pro-2026.web.app](https://apliarte-click-pro-2026.web.app)
- **GitHub**: [github.com/erbolamm/ApliArteClick](https://github.com/erbolamm/ApliArteClick)
- **Soporte**: [apliarte.com/soporte](https://apliarte.com/soporte)

## ⭐ Contribuir

Si te gusta esta aplicación:
1. Dale una ⭐ en GitHub
2. Compártela con tus amigos
3. Reporta bugs o sugiere mejoras en Issues
4. Visita [apliarte.com](https://apliarte.com) para más herramientas

---

**Hecho con ❤️ por ApliArte**  
*Desarrollado con Flutter y asistencia de Antigravity (Google DeepMind)*
