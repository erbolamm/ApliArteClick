import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import 'mouse_service.dart';

/// Global Navigator Key for context-less navigation and dialogs.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Entry point of the application.
/// Initializes the window manager, hotkey manager, and starts the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll(); // Clear previous session keys

  WindowOptions windowOptions = const WindowOptions(
    size: Size(850, 650),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    alwaysOnTop: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setAsFrameless();
  });

  runApp(const ProviderScope(child: ApliArteClickApp()));
}

class ApliArteClickApp extends StatelessWidget {
  const ApliArteClickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'ApliArte Auto-Clicker Pro',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

/// Application State Model
/// Holds all configuration and live status of the auto-clicker.
class ClickSettings {
  final bool isRunning;
  final int hours;
  final int minutes;
  final int seconds;
  final int milliseconds;
  final int clickCount;
  final bool hasPermission;
  final double? targetX;
  final double? targetY;
  final double liveX;
  final double liveY;

  final bool isPickingPosition;

  final LogicalKeyboardKey shortcut;

  ClickSettings({
    this.isRunning = false,
    this.isPickingPosition = false,
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 10,
    this.milliseconds = 0,
    this.clickCount = 0,
    this.hasPermission = true,
    this.targetX,
    this.targetY,
    this.liveX = 0,
    this.liveY = 0,
    this.shortcut = LogicalKeyboardKey.f6,
  });

  int get totalIntervalMs {
    return (hours * 3600000) +
        (minutes * 60000) +
        (seconds * 1000) +
        milliseconds;
  }

  ClickSettings copyWith({
    bool? isRunning,
    bool? isPickingPosition,
    int? hours,
    int? minutes,
    int? seconds,
    int? milliseconds,
    int? clickCount,
    bool? hasPermission,
    double? targetX,
    double? targetY,
    double? liveX,
    double? liveY,
    LogicalKeyboardKey? shortcut,
    bool clearTarget = false,
  }) {
    return ClickSettings(
      isRunning: isRunning ?? this.isRunning,
      isPickingPosition: isPickingPosition ?? this.isPickingPosition,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
      milliseconds: milliseconds ?? this.milliseconds,
      clickCount: clickCount ?? this.clickCount,
      hasPermission: hasPermission ?? this.hasPermission,
      targetX: clearTarget ? null : (targetX ?? this.targetX),
      targetY: clearTarget ? null : (targetY ?? this.targetY),
      liveX: liveX ?? this.liveX,
      liveY: liveY ?? this.liveY,
      shortcut: shortcut ?? this.shortcut,
    );
  }
}

final clickSettingsProvider =
    NotifierProvider<ClickSettingsNotifier, ClickSettings>(() {
      return ClickSettingsNotifier();
    });

/// Main application logic and state controller.
/// Manages timers, hotkey registration, and native interactions.
class ClickSettingsNotifier extends Notifier<ClickSettings> {
  @override
  ClickSettings build() {
    _initHotkeys();
    return ClickSettings();
  }

  Timer? _timer;
  final _mouseService = MouseService.create();

  void _initHotkeys() async {
    await hotKeyManager.unregisterAll();
    HotKey hotKey = HotKey(
      key: state.shortcut,
      modifiers: [],
      identifier: 'toggle_clicking',
      scope: HotKeyScope.system,
    );
    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) => toggleViaHotkey(),
    );
  }

  void updateShortcut(LogicalKeyboardKey newKey) {
    state = state.copyWith(shortcut: newKey);
    _initHotkeys();
  }

  void toggleClicking(BuildContext context) async {
    if (state.isRunning) {
      stop();
    } else {
      final hasPerm = await _mouseService.checkPermissions();
      if (!hasPerm) {
        state = state.copyWith(hasPermission: false);
        return;
      }

      // Show confirmation dialog before starting
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text(
            "⚠️ ATENCIÓN",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Estás a punto de iniciar el auto-clicker."),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.keyboard, color: Colors.blueAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Usa la tecla ${state.shortcut.keyLabel} para DETENER el clicker en cualquier momento.",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                start();
              },
              child: const Text("ENTENDIDO, EMPEZAR"),
            ),
          ],
        ),
      );
    }
  }

  void toggleViaHotkey() async {
    if (state.isRunning) {
      stop();
    } else {
      final hasPerm = await _mouseService.checkPermissions();
      if (hasPerm) start();
    }
  }

  void start() {
    final interval = state.totalIntervalMs;
    if (interval <= 0) return;

    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(Duration(milliseconds: interval), (timer) async {
      await _mouseService.performClick(x: state.targetX, y: state.targetY);
      state = state.copyWith(clickCount: state.clickCount + 1);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
  }

  void updateTime({int? h, int? m, int? s, int? ms}) {
    state = state.copyWith(
      hours: h?.clamp(0, 24),
      minutes: m?.clamp(0, 59),
      seconds: s?.clamp(0, 59),
      milliseconds: ms?.clamp(0, 999),
    );
  }

  Future<void> startPicking() async {
    await windowManager.setHasShadow(false);
    await windowManager.setIgnoreMouseEvents(false);
    await windowManager.setFullScreen(true);
    state = state.copyWith(isPickingPosition: true, liveX: 0, liveY: 0);
  }

  void updateLivePosition(Offset pos) {
    state = state.copyWith(liveX: pos.dx, liveY: pos.dy);
  }

  void endPicking(Offset globalPos) async {
    await windowManager.setFullScreen(false);
    await windowManager.setHasShadow(true);
    await windowManager.setSize(const Size(850, 650));
    await windowManager.center();

    final osPos = await _mouseService.getMousePosition();
    if (osPos != null) {
      state = state.copyWith(
        targetX: osPos['x'],
        targetY: osPos['y'],
        isPickingPosition: false,
      );
    } else {
      state = state.copyWith(isPickingPosition: false);
    }
  }

  Future<void> recordPosition() async {
    final pos = await _mouseService.getMousePosition();
    if (pos != null) {
      state = state.copyWith(targetX: pos['x'], targetY: pos['y']);
    }
  }

  void clearPosition() {
    state = state.copyWith(clearTarget: true);
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(clickSettingsProvider);
    final notifier = ref.read(clickSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          IgnorePointer(
            ignoring: settings.isPickingPosition,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: settings.isPickingPosition ? 0.0 : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blueGrey.shade900.withAlpha(240),
                      Colors.black,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withAlpha(30)),
                ),
                child: Column(
                  children: [
                    _buildTitleBar(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column: Configuration
                            Expanded(
                              flex: 3,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildBranding(),
                                    const SizedBox(height: 30),
                                    _buildCoordinatePicker(settings, notifier),
                                    const SizedBox(height: 25),
                                    _buildAdvancedTimer(settings, notifier),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                            const VerticalDivider(
                              color: Colors.white12,
                              width: 1,
                            ),
                            const SizedBox(width: 40),
                            // Right Column: Action & Shortcut
                            Expanded(
                              flex: 2,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildStats(settings),
                                    const SizedBox(height: 30),
                                    _buildShortcutRecorder(settings, notifier),
                                    const SizedBox(height: 30),
                                    _buildMainButton(
                                      settings,
                                      notifier,
                                      context,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildShortcutHint(settings),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (settings.isPickingPosition)
            Positioned.fill(
              child: MouseRegion(
                onHover: (event) => notifier.updateLivePosition(event.position),
                child: GestureDetector(
                  onTapDown: (details) {
                    notifier.endPicking(details.globalPosition);
                  },
                  child: Container(
                    color: Colors.black.withAlpha(200),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add_location_alt,
                                size: 80,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                "SELECCIONA EL PUNTO DE CLICK",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Haz click en cualquier lugar para grabar",
                                style: TextStyle(color: Colors.white54),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(20),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "EL PANEL SE HA OCULTADO PARA TU VISIBILIDAD",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Cursor follower coordinate label - Shifted further from cursor
                        Positioned(
                          left: settings.liveX + 40,
                          top: settings.liveY + 40,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withAlpha(230),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "COORDENADAS",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withAlpha(180),
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "X: ${settings.liveX.round()}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Y: ${settings.liveY.round()}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Crosshair pointer
                        Positioned(
                          left: settings.liveX - 25,
                          top: settings.liveY - 25,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blueAccent.withAlpha(180),
                                width: 1.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                size: 24,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleBar() {
    return DragToMoveArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "APLIARTE PRO",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.blueAccent,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.white38),
              onPressed: () => exit(0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.blueAccent, Colors.cyanAccent],
          ).createShader(bounds),
          child: Text(
            "ApliArte",
            style: GoogleFonts.outfit(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -2,
            ),
          ),
        ),
        Text(
          "PRO AUTO-CLICKER",
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white38,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            TextButton(
              onPressed: () => launchUrl(Uri.parse('https://apliarte.com')),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                "apliarte.com",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(width: 15),
            ElevatedButton.icon(
              onPressed: () => launchUrl(Uri.parse('https://apliarte.com')),
              icon: const Icon(Icons.apps, size: 14),
              label: const Text(
                "VER MIS APLICACIONES",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withAlpha(10),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats(ClickSettings settings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Column(
        children: [
          Text(
            "${settings.clickCount}",
            style: GoogleFonts.jetBrainsMono(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
            ),
          ),
          const Text(
            "TOTAL CLICKS",
            style: TextStyle(
              fontSize: 10,
              color: Colors.white38,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinatePicker(
    ClickSettings settings,
    ClickSettingsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CLICK LOCATION",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white38,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  settings.targetX == null
                      ? "Follow Cursor"
                      : "Fixed: [${settings.targetX!.round()}, ${settings.targetY!.round()}]",
                  style: TextStyle(
                    color: settings.targetX == null
                        ? Colors.white38
                        : Colors.white,
                  ),
                ),
              ),
              if (settings.targetX != null)
                IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 16,
                    color: Colors.redAccent,
                  ),
                  onPressed: notifier.clearPosition,
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: notifier.startPicking,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.redAccent.withAlpha(100),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedTimer(
    ClickSettings settings,
    ClickSettingsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "INTERVAL REPEAT",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white38,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTimeUnit(
              "H",
              settings.hours,
              (v) => notifier.updateTime(h: settings.hours + v),
            ),
            _buildTimeUnit(
              "M",
              settings.minutes,
              (v) => notifier.updateTime(m: settings.minutes + v),
            ),
            _buildTimeUnit(
              "S",
              settings.seconds,
              (v) => notifier.updateTime(s: settings.seconds + v),
            ),
            _buildTimeUnit(
              "MS",
              settings.milliseconds,
              (v) => notifier.updateTime(ms: settings.milliseconds + (v * 10)),
              step: 10,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeUnit(
    String label,
    int value,
    Function(int) onDelta, {
    int step = 1,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white24)),
        const SizedBox(height: 4),
        Container(
          width: 70,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up, size: 16),
                onPressed: () => onDelta(step),
              ),
              Text(
                "$value",
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                onPressed: () => onDelta(-step),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainButton(
    ClickSettings settings,
    ClickSettingsNotifier notifier,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => notifier.toggleClicking(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: settings.isRunning
                ? [Colors.redAccent, Colors.red.shade900]
                : [Colors.blueAccent, Colors.blue.shade900],
          ),
          boxShadow: [
            BoxShadow(
              color: (settings.isRunning ? Colors.redAccent : Colors.blueAccent)
                  .withAlpha(100),
              blurRadius: 25,
              spreadRadius: -5,
            ),
          ],
        ),
        child: Center(
          child: Text(
            settings.isRunning ? "STOP CLICKING" : "START AUTO-CLICK",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutHint(ClickSettings settings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Usa ${settings.shortcut.keyLabel} para Iniciar/Parar",
        style: const TextStyle(fontSize: 11, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildShortcutRecorder(
    ClickSettings settings,
    ClickSettingsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ACCESO RÁPIDO PARA PARAR",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white38,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              const Icon(Icons.keyboard, color: Colors.white38, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Tecla: ${settings.shortcut.keyLabel}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () =>
                    _showShortcutPicker(navigatorKey.currentContext!, notifier),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.withAlpha(40),
                  foregroundColor: Colors.blueAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("CAMBIAR"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showShortcutPicker(
    BuildContext context,
    ClickSettingsNotifier notifier,
  ) {
    final fKeys = [
      LogicalKeyboardKey.f1,
      LogicalKeyboardKey.f2,
      LogicalKeyboardKey.f3,
      LogicalKeyboardKey.f4,
      LogicalKeyboardKey.f5,
      LogicalKeyboardKey.f6,
      LogicalKeyboardKey.f7,
      LogicalKeyboardKey.f8,
      LogicalKeyboardKey.f9,
      LogicalKeyboardKey.f10,
      LogicalKeyboardKey.f11,
      LogicalKeyboardKey.f12,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "SELECCIONA TECLA DE EMERGENCIA",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: fKeys
                  .map(
                    (key) => ElevatedButton(
                      onPressed: () {
                        notifier.updateShortcut(key);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withAlpha(10),
                        foregroundColor: Colors.white,
                        fixedSize: const Size(80, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(key.keyLabel),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
