import 'dart:async';
import 'dart:io';
import 'dart:math';

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
      home: const AppRouter(),
    );
  }
}

/// Types of actions the auto-clicker can perform.
enum ActionType { mouseClick, keyboard }

/// Application State Model
/// Holds all configuration and live status of the auto-clicker.
class ClickSettings {
  final bool isRunning;
  final ActionType actionType;
  final LogicalKeyboardKey? keyboardActionKey;
  final bool useControl;
  final bool useShift;
  final bool useAlt;
  final bool useCommand;
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
  final bool showWelcome;

  final LogicalKeyboardKey shortcut;

  ClickSettings({
    this.isRunning = false,
    this.isPickingPosition = false,
    this.showWelcome = true,
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
    this.actionType = ActionType.mouseClick,
    this.keyboardActionKey,
    this.useControl = false,
    this.useShift = false,
    this.useAlt = false,
    this.useCommand = false,
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
    bool? showWelcome,
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
    ActionType? actionType,
    LogicalKeyboardKey? keyboardActionKey,
    bool? useControl,
    bool? useShift,
    bool? useAlt,
    bool? useCommand,
    bool clearTarget = false,
    bool clearKeyboardAction = false,
  }) {
    return ClickSettings(
      isRunning: isRunning ?? this.isRunning,
      showWelcome: showWelcome ?? this.showWelcome,
      actionType: actionType ?? this.actionType,
      keyboardActionKey: clearKeyboardAction
          ? null
          : (keyboardActionKey ?? this.keyboardActionKey),
      useControl: useControl ?? this.useControl,
      useShift: useShift ?? this.useShift,
      useAlt: useAlt ?? this.useAlt,
      useCommand: useCommand ?? this.useCommand,
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
    try {
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
    } catch (e) {
      print('Error registering hotkey: $e');
      // Continue without hotkey if registration fails
    }
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
      if (state.actionType == ActionType.mouseClick) {
        await _mouseService.performClick(x: state.targetX, y: state.targetY);
      } else if (state.actionType == ActionType.keyboard &&
          state.keyboardActionKey != null) {
        final code = _getNativeKeyCode(state.keyboardActionKey!);
        if (code != null) {
          await _mouseService.performKeyPress(
            code,
            modifiers: [
              if (state.useControl) 'control',
              if (state.useShift) 'shift',
              if (state.useAlt) 'alt',
              if (state.useCommand) 'command',
            ],
          );
        }
      }
      state = state.copyWith(clickCount: state.clickCount + 1);
    });
  }

  void updateActionType(ActionType type) {
    state = state.copyWith(actionType: type);
  }

  void setAltTabPreset() {
    state = state.copyWith(
      actionType: ActionType.keyboard,
      keyboardActionKey: LogicalKeyboardKey.tab,
      useAlt: !Platform.isMacOS,
      useCommand: Platform.isMacOS,
      useControl: false,
      useShift: false,
    );
  }

  void updateKeyboardActionKey(LogicalKeyboardKey key) {
    state = state.copyWith(keyboardActionKey: key);
  }

  void toggleControl() => state = state.copyWith(useControl: !state.useControl);
  void toggleShift() => state = state.copyWith(useShift: !state.useShift);
  void toggleAlt() => state = state.copyWith(useAlt: !state.useAlt);
  void toggleCommand() => state = state.copyWith(useCommand: !state.useCommand);

  int? _getNativeKeyCode(LogicalKeyboardKey key) {
    if (Platform.isMacOS) {
      if (key == LogicalKeyboardKey.enter) return 36;
      if (key == LogicalKeyboardKey.space) return 49;
      if (key == LogicalKeyboardKey.escape) return 53;
      if (key == LogicalKeyboardKey.keyA) return 0;
      if (key == LogicalKeyboardKey.keyS) return 1;
      if (key == LogicalKeyboardKey.keyD) return 2;
      if (key == LogicalKeyboardKey.keyF) return 3;
      if (key == LogicalKeyboardKey.keyH) return 4;
      if (key == LogicalKeyboardKey.keyG) return 5;
      if (key == LogicalKeyboardKey.keyZ) return 6;
      if (key == LogicalKeyboardKey.keyX) return 7;
      if (key == LogicalKeyboardKey.keyC) return 8;
      if (key == LogicalKeyboardKey.keyV) return 9;
      if (key == LogicalKeyboardKey.keyB) return 11;
      if (key == LogicalKeyboardKey.keyQ) return 12;
      if (key == LogicalKeyboardKey.keyW) return 13;
      if (key == LogicalKeyboardKey.keyE) return 14;
      if (key == LogicalKeyboardKey.keyR) return 15;
      if (key == LogicalKeyboardKey.keyY) return 16;
      if (key == LogicalKeyboardKey.keyT) return 17;

      if (key.keyId >= LogicalKeyboardKey.f1.keyId &&
          key.keyId <= LogicalKeyboardKey.f12.keyId) {
        final fIdx = key.keyId - LogicalKeyboardKey.f1.keyId;
        final fCodes = [122, 120, 99, 118, 96, 97, 98, 100, 101, 109, 103, 111];
        return fCodes[fIdx];
      }
    } else if (Platform.isWindows) {
      // Special mapping for Windows VK codes
      if (key == LogicalKeyboardKey.enter) return 0x0D;
      if (key == LogicalKeyboardKey.space) return 0x20;
      if (key == LogicalKeyboardKey.escape) return 0x1B;
      if (key.keyId >= LogicalKeyboardKey.keyA.keyId &&
          key.keyId <= LogicalKeyboardKey.keyZ.keyId) {
        return 0x41 + (key.keyId - LogicalKeyboardKey.keyA.keyId);
      }
      if (key.keyId >= LogicalKeyboardKey.f1.keyId &&
          key.keyId <= LogicalKeyboardKey.f12.keyId) {
        return 0x70 + (key.keyId - LogicalKeyboardKey.f1.keyId);
      }
    }
    return null;
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

  Timer? _dodgeTimer;
  Timer? _clickCheckTimer;

  Future<void> startPicking() async {
    state = state.copyWith(isPickingPosition: true);

    // Monitor for mouse clicks to save position automatically
    _clickCheckTimer = Timer.periodic(const Duration(milliseconds: 50), (
      timer,
    ) async {
      final isClicking = await _mouseService.isMouseButtonPressed();
      if (isClicking) {
        // User clicked - save position immediately
        endPicking();
      }
    });

    _dodgeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _checkAndDodge();
    });
  }

  Future<void> _checkAndDodge() async {
    final mousePos = await _mouseService.getMousePosition();
    if (mousePos == null) return;

    final windowRect = await windowManager.getBounds();
    final mousePoint = Point(mousePos['x']!, mousePos['y']!);

    // Check if mouse is near window (with 50px padding)
    final dodgeRect = Rect.fromLTWH(
      windowRect.left - 50,
      windowRect.top - 50,
      windowRect.width + 100,
      windowRect.height + 100,
    );

    if (dodgeRect.contains(
      Offset(mousePoint.x.toDouble(), mousePoint.y.toDouble()),
    )) {
      // Dodge! Move to a different corner
      final screen = await _getPrimaryScreenSize();
      final currentPos = await windowManager.getPosition();

      double newX = 50;
      double newY = 50;

      if (currentPos.dx < screen.width / 2) {
        newX = screen.width - windowRect.width - 50;
      } else {
        newX = 50;
      }

      if (currentPos.dy < screen.height / 2) {
        newY = screen.height - windowRect.height - 50;
      } else {
        newY = 50;
      }

      await windowManager.setPosition(Offset(newX, newY));
    }

    // Update live pos just for the HUD
    state = state.copyWith(liveX: mousePos['x']!, liveY: mousePos['y']!);
  }

  Future<Size> _getPrimaryScreenSize() async {
    // Fallback if we can't get it, but usually windows/macos handles this via window manager
    return const Size(1920, 1080);
  }

  void updateLivePosition(Offset pos) {
    state = state.copyWith(liveX: pos.dx, liveY: pos.dy);
  }

  void endPicking() async {
    _dodgeTimer?.cancel();
    _dodgeTimer = null;

    _clickCheckTimer?.cancel();
    _clickCheckTimer = null;

    // No hotkey to unregister

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

  void updateShowWelcome(bool show) {
    state = state.copyWith(showWelcome: show);
  }

  void clearPosition() {
    state = state.copyWith(clearTarget: true);
  }
}

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(clickSettingsProvider);

    if (settings.showWelcome) {
      return const WelcomeScreen();
    }
    return const MainScreen();
  }
}

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueGrey.shade900.withAlpha(240), Colors.black],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withAlpha(30)),
        ),
        child: Column(
          children: [
            _buildWelcomeTitleBar(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 180,
                        height: 180,
                      ),
                      const SizedBox(height: 30),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.blueAccent, Colors.cyanAccent],
                        ).createShader(bounds),
                        child: Text(
                          "ApliArte Click",
                          style: GoogleFonts.outfit(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "PRO AUTO-CLICKER",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white38,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withAlpha(10)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "¡Gracias por usar mi aplicación!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            _buildWelcomeLink(
                              Icons.language,
                              "Visita apliarte.com",
                              "https://apliarte.com",
                            ),
                            const SizedBox(height: 12),
                            _buildWelcomeLink(
                              Icons.apps,
                              "Ver más aplicaciones",
                              "https://www.apliarte.com/p/apps-para-ti.html",
                            ),
                            const SizedBox(height: 12),
                            _buildWelcomeLink(
                              Icons.star,
                              "Dale una estrella en GitHub",
                              "https://github.com/apliarte",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(clickSettingsProvider.notifier)
                              .updateShowWelcome(false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                        child: const Text(
                          "ENTRAR",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeTitleBar() {
    return DragToMoveArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.white38),
              onPressed: () => exit(0),
              tooltip: "Cerrar",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeLink(IconData icon, String label, String url) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blueAccent, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blueGrey.shade900.withAlpha(240), Colors.black],
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
                                const SizedBox(height: 10),
                                _buildActionSelector(settings, notifier),
                                const SizedBox(height: 25),
                                if (settings.actionType ==
                                    ActionType.mouseClick) ...[
                                  _buildCoordinatePicker(settings, notifier),
                                  const SizedBox(height: 25),
                                ],
                                _buildAdvancedTimer(settings, notifier),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                        const VerticalDivider(color: Colors.white12, width: 1),
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
                                _buildMainButton(settings, notifier, context),
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
          if (settings.isPickingPosition)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withAlpha(220),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(100),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "MODO GRABACIÓN ACTIVO",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Localización: [${settings.liveX.toInt()}, ${settings.liveY.toInt()}]",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: notifier.endPicking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text("GUARDAR POSICIÓN"),
                      ),
                    ],
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(5),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.blueAccent, Colors.cyanAccent],
              ).createShader(bounds),
              child: Text(
                "ApliArte",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "PRO CLICKER",
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white38,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => launchUrl(Uri.parse('https://apliarte.com')),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
              ),
              child: const Text(
                "apliarte.com",
                style: TextStyle(color: Colors.blueAccent, fontSize: 11),
              ),
            ),
            const SizedBox(width: 8),
            _buildAppsButton(),
            const SizedBox(width: 12),
            Container(height: 24, width: 1, color: Colors.white10),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.white38),
              onPressed: () => exit(0),
              tooltip: "Cerrar",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppsButton() {
    return TextButton.icon(
      onPressed: () =>
          launchUrl(Uri.parse('https://www.apliarte.com/p/apps-para-ti.html')),
      icon: const Icon(Icons.apps, size: 16, color: Colors.white70),
      label: const Text(
        "APPS",
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: Size.zero,
        backgroundColor: Colors.white.withAlpha(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
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
            "ACCIONES",
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

  Widget _buildActionSelector(
    ClickSettings settings,
    ClickSettingsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TIPO DE ACCIÓN",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white38,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  "RATÓN",
                  Icons.mouse,
                  settings.actionType == ActionType.mouseClick,
                  () => notifier.updateActionType(ActionType.mouseClick),
                ),
              ),
              Expanded(
                child: _buildActionButton(
                  "TECLADO / ACCIONES",
                  Icons.keyboard,
                  settings.actionType == ActionType.keyboard,
                  () => notifier.updateActionType(ActionType.keyboard),
                ),
              ),
            ],
          ),
        ),
        if (settings.actionType == ActionType.keyboard) ...[
          const SizedBox(height: 15),
          _buildQuickPresets(notifier),
          const SizedBox(height: 15),
          _buildModifierToggles(settings, notifier),
          const SizedBox(height: 15),
          _buildKeyActionPicker(settings, notifier),
        ],
      ],
    );
  }

  Widget _buildQuickPresets(ClickSettingsNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ACCIONES RÁPIDAS",
          style: TextStyle(
            fontSize: 10,
            color: Colors.white38,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: notifier.setAltTabPreset,
          icon: const Icon(Icons.tab, size: 16),
          label: Text(
            Platform.isMacOS ? "CONFIGURAR CMD + TAB" : "CONFIGURAR ALT + TAB",
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent.withAlpha(30),
            foregroundColor: Colors.blueAccent,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.blueAccent.withAlpha(50)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.white38,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModifierToggles(
    ClickSettings settings,
    ClickSettingsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "COMBINACIÓN ESPECIAL (MODIFICADORES)",
          style: TextStyle(
            fontSize: 10,
            color: Colors.white38,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildModifierChip(
              "Ctrl",
              settings.useControl,
              notifier.toggleControl,
            ),
            _buildModifierChip(
              "Shift",
              settings.useShift,
              notifier.toggleShift,
            ),
            _buildModifierChip(
              "Alt / Opt",
              settings.useAlt,
              notifier.toggleAlt,
            ),
            _buildModifierChip(
              Platform.isMacOS ? "Cmd (⌘)" : "Win",
              settings.useCommand,
              notifier.toggleCommand,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModifierChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.white10,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildKeyActionPicker(
    ClickSettings settings,
    ClickSettingsNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TECLA A REPETIR",
                  style: TextStyle(fontSize: 9, color: Colors.white38),
                ),
                Text(
                  settings.keyboardActionKey?.keyLabel ?? "Sin asignar",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showShortcutPicker(
              navigatorKey.currentContext!,
              notifier,
              isActionKey: true,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent.withAlpha(40),
              foregroundColor: Colors.blueAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("ASIGNAR"),
          ),
        ],
      ),
    );
  }

  void _showShortcutPicker(
    BuildContext context,
    ClickSettingsNotifier notifier, {
    bool isActionKey = false,
  }) {
    final keys = isActionKey
        ? [
            LogicalKeyboardKey.enter,
            LogicalKeyboardKey.space,
            LogicalKeyboardKey.keyA,
            LogicalKeyboardKey.keyS,
            LogicalKeyboardKey.keyD,
            LogicalKeyboardKey.keyF,
            LogicalKeyboardKey.keyW,
            LogicalKeyboardKey.keyE,
            LogicalKeyboardKey.keyQ,
            LogicalKeyboardKey.keyR,
            LogicalKeyboardKey.tab,
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
          ]
        : [
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isActionKey
                    ? "SELECCIONA TECLA A REPETIR"
                    : "SELECCIONA TECLA DE EMERGENCIA",
                style: const TextStyle(
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
                children: keys
                    .map(
                      (key) => ElevatedButton(
                        onPressed: () {
                          if (isActionKey) {
                            notifier.updateKeyboardActionKey(key);
                          } else {
                            notifier.updateShortcut(key);
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withAlpha(10),
                          foregroundColor: Colors.white,
                          fixedSize: const Size(100, 45),
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
      ),
    );
  }
}
