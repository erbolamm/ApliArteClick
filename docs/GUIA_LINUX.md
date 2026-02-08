# 🐧 Guía para Linux (Próximamente)

Esta guía detalla los pasos para compilar, empaquetar y distribuir ApliArte Click Pro en sistemas Linux.

## 🛠 Requisitos Previos

- **Flutter SDK**: Instalado y configurado.
- **Dependencias de compilación**:

  ```bash
  sudo apt-get update
  sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
  ```

## 🏗 Compilación

```bash
# Limpiar y obtener dependencias
flutter clean
flutter pub get

# Generar el ejecutable
flutter build linux --release
```

El ejecutable se generará en: `build/linux/x64/release/bundle/apliarte_click`

## 📦 Empaquetado

### Opción A - Tarball (.tar.xz)

Comprime la carpeta `bundle` completa:

```bash
cd build/linux/x64/release/
tar -cJf ApliArteClickPro-Linux-v3.0.0.tar.xz bundle/
```

### Opción B - AppImage / Flatpak

*(Próximamente instrucciones detalladas para creación de AppImage)*

## 🚀 Instalación por Terminal

Se espera crear un script `install_linux.sh` similar al de macOS:

```bash
# Ejemplo futuro
curl -fsSL https://raw.githubusercontent.com/erbolamm/ApliArteClick/main/install_linux.sh | bash
```

## 📄 Notas de Desarrollo

- **Permisos**: Es posible que se necesiten permisos adicionales para simular eventos de teclado y ratón (X11 vs Wayland).
- **Wayland**: Actualmente Wayland tiene restricciones de seguridad severas para la simulación de entrada. Se recomienda usar X11 para máxima compatibilidad.
