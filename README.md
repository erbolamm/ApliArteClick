# ApliArte Click Pro 🎯🖱️

**¡Presentamos la Versión 3.0 (Advanced)!** 🚀

Un auto-clicker profesional multiplataforma con interfaz moderna, secuencias mixtas, bucles avanzados y control total de flujo.

**Web Oficial**: [apliarte-click-pro-2026.web.app](https://apliarte-click-pro-2026.web.app)

![ApliArte Click Logo](landing_page/assets/images/logo.svg)

## 🌟 Novedades en Versión 3.0 (ADVANCED)

### 🔄 Control de Flujo Avanzado
- **Bucles (Loops)**: Agrupa acciones y repítelas N veces con un solo contenedor.
- **Drag & Drop**: Arrastra acciones dentro de bucles para anidarlas o reordenarlas.
- **Pausa y Stop**: Control total - pausa la ejecución o detén secuencias en puntos específicos.

### ⌨️ Mejoras en Atajos de Teclado
- **Visualización de Modificadores**: Ahora verás "Alt + B" en lugar de solo "B".
- **Captura Mejorada**: Instrucciones claras paso a paso para grabar combinaciones correctamente.

### 🎨 UI Mejorada
- **Info Screen Premium**: Guía visual con emojis, ejemplos y botón de sugerencias por email.
- **Timer Editor Responsive**: Los campos de tiempo se actualizan mientras escribes.
- **Reordenamiento en Bucles**: Reorganiza acciones anidadas con drag & drop.

---

## 📥 Descargas y Versiones

Ofrecemos tres versiones para adaptarse a tus necesidades:

### Versión 3.0.0 (Recomendada - ADVANCED) ✨
La versión más potente con bucles, control de flujo y mejoras en la UI.
- **macOS**: [ApliArteClickPro-macOS-v3.0.0.zip](https://github.com/erbolamm/ApliArteClick/releases/download/v3.0.0/ApliArteClickPro-macOS-v3.0.0.zip)

### Versión 2.0.0 (PRO) 🔥
Secuencias mixtas con clicks y teclas, librería de acciones guardadas.
- **macOS**: [ApliArteClickPro-macOS-v2.0.0.zip](https://github.com/erbolamm/ApliArteClick/releases/download/v2.0.0/ApliArteClickPro-macOS-v2.0.0.zip)

### Versión 1.0.0 (Clásica - Legacy) 🏛️
La versión original simple, para automatizaciones básicas de un solo punto.
- **macOS**: [ApliArteClickPro-macOS-v1.0.0.zip](https://github.com/erbolamm/ApliArteClick/releases/download/v1.0.0/ApliArteClickPro-macOS-v1.0.0.zip)

---

## 🚀 Instalación Rápida (Terminal)

Puedes instalar cualquiera de las tres versiones usando nuestro script inteligente:

### Instalar V3.0 (Por Defecto)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/erbolamm/ApliArteClick/main/install.sh)"
```

### Instalar V2.0 (Específica)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/erbolamm/ApliArteClick/main/install.sh)" -- v2.0.0
```

### Instalar V1.0 (Específica)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/erbolamm/ApliArteClick/main/install.sh)" -- v1.0.0
```

---

## 🎮 Guía de Uso Rápido (V3.0)

1. **Añadir Acción**: Pulsa el botón `+` azul para añadir Click, Tecla, Texto, Bucle, Pausa o Stop.
2. **Configurar**: 
   - **Click**: Pulsa "GRABAR POSICIÓN" y haz clic donde quieras.
   - **Tecla**: Pulsa "TECLA / ATAJO" y mantén los modificadores (Alt, Cmd) mientras presionas la tecla.
   - **Bucle**: Arrastra acciones al ícono ∞ para anidarlas. Usa el icono ☰ para reordenar.
3. **Librería**: Usa el icono 📂 para cargar acciones guardadas o predefinidas.
4. **Guardar**: Usa el icono 💾 para guardar tu secuencia actual.
5. **Ejecutar**: Pulsa el botón Play ▶️ o usa tu tecla de atajo (F6 por defecto).

## 🔧 Desarrollo y Compilación

### Requisitos
- Flutter 3.10.7+
- macOS: Xcode 14+

### Comandos de Build
El proyecto incluye un script `build.sh` para facilitar la tarea:

```bash
# Compilar V2.0 para macOS
./build.sh macos
```

## 🔐 Privacidad y Permisos (macOS)
- **Accesibilidad**: Requiere permisos de accesibilidad para simular los clics y teclas. Se solicitará automáticamente al abrir la app.
- **Seguridad**: La app no recopila datos ni conecta a internet salvo para abrir la web oficial.

## 📝 Licencia
© 2026 ApliArte. Todos los derechos reservados.

---
**Hecho con ❤️ por ApliArte**  
*Desarrollado con Flutter y asistencia de Antigravity (Google DeepMind)*
