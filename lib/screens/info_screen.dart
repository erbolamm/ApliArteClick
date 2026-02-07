import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        margin: const EdgeInsets.all(40),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Instrucciones de ApliArte Click",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.email_outlined,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () async {
                          final uri = Uri(
                            scheme: 'mailto',
                            path: 'info@apliarte.com',
                            query: 'subject=Sugerencia desde ApliArteClick',
                          );
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        tooltip: "Enviar sugerencia",
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: "Cerrar",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white10),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      icon: Icons.rocket_launch,
                      title: "Inicio Rápido",
                      examples: [
                        "1️⃣ Pulsa 'Grabar Posición' o **F6**",
                        "2️⃣ Haz clic donde quieras que el bot haga clic",
                        "3️⃣ Pulsa **F6** para terminar de grabar",
                        "4️⃣ Usa el botón **+** para agregar más acciones",
                        "5️⃣ Pulsa **Play** (o F6) para ejecutar",
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildSection(
                      icon: Icons.mouse,
                      title: "Tipos de Click",
                      examples: [
                        "🖱️ Clic Izquierdo → Clic normal",
                        "🖱️ Clic Derecho → Se detecta automáticamente",
                        "🖱️ Doble Clic → Haz clic rápido 2 veces (se guarda como 'x2')",
                        "🖱️ Triple Clic → Haz clic rápido 3 veces (se guarda como 'x3')",
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildSection(
                      icon: Icons.keyboard,
                      title: "Cómo Grabar Atajos de Teclado",
                      examples: [
                        "⌨️ Pulsa el botón **+** → Selecciona 'Tecla / Atajo'",
                        "⌨️ MANTÉN presionadas las teclas modificadoras (Cmd ⌘, Alt ⌥, Ctrl ⌃, Shift ⇧)",
                        "⌨️ MIENTRAS las mantienes, presiona la tecla principal",
                        "",
                        "📌 Ejemplo: Para grabar 'Alt + B':",
                        "   1. Mantén presionada la tecla Alt ⌥",
                        "   2. Sin soltar Alt, presiona B",
                        "   3. Verás 'Alt + B' en la pantalla",
                        "   4. Confirma para guardar",
                        "",
                        "⚠️ IMPORTANTE: NO sueltes los modificadores hasta ver",
                        "   la combinación completa en pantalla",
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildSection(
                      icon: Icons.auto_awesome,
                      title: "Acciones Avanzadas (Botón +)",
                      examples: [
                        "🖱️ Click de Ratón → Selecciona posición manualmente",
                        "⌨️ Tecla/Atajo → Presiona teclas o combinaciones",
                        "📝 Escribir Texto → Escribe texto automáticamente",
                        "➖",
                        "⏱️ Pausa → Espera sin hacer nada (útil para cargas)",
                        "🛑 Parar → Finaliza la secuencia inmediatamente",
                        "🔄 Bucle → Repite un grupo de acciones",
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildSection(
                      icon: Icons.loop,
                      title: "Cómo usar Bucles (Drag & Drop)",
                      examples: [
                        "1️⃣ Crea un bucle: Botón **+** → 'Bucle (Grupo)'",
                        "2️⃣ Crea las acciones que quieres repetir",
                        "3️⃣ ARRASTRA cada acción hacia el ícono ∞ del bucle",
                        "4️⃣ El ícono se pondrá **CIAN** ✨ cuando puedas soltar",
                        "5️⃣ Edita el bucle (🖊️) para cambiar repeticiones",
                        "6️⃣ Para sacar una acción: haz clic en ❌",
                        "",
                        "📌 Ejemplo: Bucle que repite 5 veces",
                        "   🔄 Bucle (5 repeticiones)",
                        "   ├─ 🖱️ Click en (100, 200)",
                        "   ├─ ⏱️ Pausa 1 segundo",
                        "   └─ ⌨️ Tecla 'B'",
                        "   → Ejecutará esas 3 acciones 5 veces seguidas",
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildSection(
                      icon: Icons.layers,
                      title: "Controles de Ventana",
                      examples: [
                        "📌 Chincheta → Fijar ventana siempre encima",
                        "🖥️ Sin chincheta → Ventana normal (Mission Control)",
                        "💾 Guardar → Guarda secuencias para reutilizar",
                        "🖊️ Editar → Modifica acciones existentes",
                        "🗑️ Borrar → Elimina acciones",
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<String> examples,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 20),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: examples.map((example) {
              if (example == "➖") {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Divider(color: Colors.white10, height: 1),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  example,
                  style: TextStyle(
                    color:
                        example.startsWith("📌") ||
                            example.startsWith("⚠️") ||
                            example.startsWith("💡")
                        ? Colors.amber.shade200
                        : Colors.white70,
                    height: 1.4,
                    fontSize: 13,
                    fontWeight:
                        example.contains("IMPORTANTE") ||
                            example.contains("Ejemplo")
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
