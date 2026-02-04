# ApliArte Click Pro 🎯🖱️

**¡Presentamos la Versión 2.0 (Pro)!** 🚀

Un auto-clicker profesional multiplataforma con interfaz moderna, secuencias mixtas y funciones avanzadas.

**Web Oficial**: [apliarte-click-pro-2026.web.app](https://apliarte-click-pro-2026.web.app)

![ApliArte Click Logo](landing_page/assets/images/logo.svg)

## 🌟 Novedades en Versión 2.0 (PRO)

### 🚀 Modo Multi-Clip & Secuencias Mixtas
- **Clicks + Teclas**: Crea secuencias complejas combinando clicks de ratón con pulsaciones de teclado.
- **Lista de Acciones**: Visualiza y reorganiza tu secuencia arrastrando y soltando.
- **Atajos Avanzados**: Soporte para "Sostener" (Hold) teclas (ej. Mantener Shift presionado mientras haces clic).

### 💾 Librería de Acciones
- **Guardar/Cargar**: Guarda tus secuencias favoritas y cárgalas con un clic.
- **Acciones Predefinidas**: Incluye macros útiles como "Cambiar App (Cmd+Tab)", "Copiar", "Pegar".

### 🎨 Nueva Interfaz Rediseñada
- **Diseño de Columna Única**: Más limpio, compacto y responsivo.
- **Mini Controles**: Intervalo y Atajos integrados en la cabecera para ahorrar espacio.
- **Responsive**: La lista de acciones se adapta al tamaño de la ventana.

---

## 📥 Descargas y Versiones

Ofrecemos dos versiones para adaptarse a tus necesidades:

### Versión 2.0.0 (Recomendada - PRO) ✨
La versión más potente con todas las nuevas funcionalidades.
- **macOS**: [ApliArteClickPro-macOS-v2.0.0.zip](https://github.com/erbolamm/ApliArteClick/releases/download/v2.0.0/ApliArteClickPro-macOS-v2.0.0.zip)

### Versión 1.0.0 (Clásica - Legacy) 🏛️
La versión original simple, para automatizaciones básicas de un solo punto.
- **macOS**: [ApliArteClickPro-macOS-v1.0.0.zip](https://github.com/erbolamm/ApliArteClick/releases/download/v1.0.0/ApliArteClickPro-macOS-v1.0.0.zip)

---

## 🚀 Instalación Rápida (Terminal)

Puedes instalar cualquiera de las dos versiones usando nuestro script inteligente:

### Instalar V2.0 (Por Defecto)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/erbolamm/ApliArteClick/main/install.sh)"
```

### Instalar V1.0 (Específica)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/erbolamm/ApliArteClick/main/install.sh)" -- v1.0.0
```

---

## 🎮 Guía de Uso Rápido (V2.0)

1. **Añadir Acción**: Pulsa el botón `+` azul para añadir un Click o una Tecla.
2. **Configurar**: 
   - **Click**: Pulsa "GRABAR POSICIÓN" y haz clic donde quieras.
   - **Tecla**: Pulsa "TECLA / ATAJO" y presiona las teclas físicas (ej. Cmd+C).
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
