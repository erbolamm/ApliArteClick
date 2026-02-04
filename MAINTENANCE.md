# 🛠️ Guía de Mantenimiento

Este documento es para uso interno (desarrolladores) y detalla cómo gestionar las versiones y publicaciones.

## 🔗 Recursos del Proyecto
- **Repositorio**: https://github.com/erbolamm/ApliArteClick
- **Landing Page**: https://apliarte-click-pro-2026.web.app
- **Firebase Console**: [apliarte-click-pro-2026](https://console.firebase.google.com/project/apliarte-click-pro-2026/overview)

## 🚀 Proceso de Lanzamiento (macOS)
Para generar una nueva versión oficial:

1.  **Limpiar y Compilar**:
    ```bash
    flutter clean
    flutter pub get
    flutter build macos --release
    ```

2.  **Empaquetar**:
    ```bash
    cd build/macos/Build/Products/Release
    zip -r ../../../../../ApliArteClickPro-macOS-v1.1.0.zip "ApliArte Clicker.app"
    ```

3.  **Etiquetar en Git**:
    ```bash
    git tag v1.1.0
    git push origin v1.1.0
    ```

4.  **GitHub Release**:
    - Ve a [GitHub Releases](https://github.com/erbolamm/ApliArteClick/releases).
    - Crea un nuevo release usando el tag `v1.1.0`.
    - Sube el archivo `.zip` generado.

## 🌐 Actualizar la Landing Page
La web está en la carpeta `/landing_page`.

1.  Realiza los cambios en `index.html` o `style.css`.
2.  Despliega:
    ```bash
    firebase deploy --only hosting
    ```
3.  **Nota**: Si cambias el `install.sh`, asegúrate de actualizar el checksum o la URL en el `index.html`.

## 🖥️ Mantenimiento del Installer Script
El archivo `install.sh` está en la raíz.
- Se descarga desde el `raw.githubusercontent.com`.
- Si lo modificas, haz `push` a `main` para que la URL pública se actualice.


## 🏪 Guía de Publicación en Tiendas (Stores)

Para llevar ApliArte Click Pro a las tiendas oficiales, sigue estos pasos:

### 🍏 Mac App Store
1.  **Requisitos**: Cuenta de Apple Developer ($99/año).
2.  **Preparación de App**:
    - Activar **App Sandbox** en Xcode (`macos/Runner/Release.entitlements`).
    - Añadir excepciones para eventos de entrada (Accesibilidad) si es posible, aunque Apple es estricto con auto-clickers en la tienda.
3.  **App Store Connect**: Crea el registro de la app con capturas y descripción.
4.  **Subida**: Usa la herramienta **Transporter** o Xcode para subir el build `.pkg` firmado.

### 🪟 Microsoft Store (Windows)
1.  **Requisitos**: Cuenta de Partner Center ($19 pago único para individuos).
2.  **Empaquetado**:
    - Usa el paquete `msix` para Flutter.
    - Ejecuta: `flutter pub add msix` y luego `flutter pub run msix:create`.
3.  **Certificación**: Sube el `.msix` al Partner Center y espera la validación de Microsoft.

---

## 📝 Notas Técnicas
- **Permisos de macOS**: La app requiere el permiso de `Coments` y `Accessibility` para simular eventos.
- **Detección de Ratón**: Usamos `NSEvent.pressedMouseButtons` en macOS y `GetAsyncKeyState` en Windows para detectar el clic en el modo grabación.
