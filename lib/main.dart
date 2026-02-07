import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apliarte_click/widgets/build_main_button.dart';
import 'package:apliarte_click/widgets/build_stats.dart';
import 'package:apliarte_click/screens/info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import 'utils/native_key_mapper.dart';

import 'mouse_service.dart';
import 'widgets/multi_clip_manager.dart';
import 'models/click_point.dart';
import 'models/saved_sequence.dart';

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
    alwaysOnTop: false,
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
enum ActionType { mouseClick, keyboard, text, stop, pause, loop }

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
  // Previously removed but still needed
  final bool isPickingPosition;
  final bool showWelcome;
  final double liveX;
  final double liveY;
  final LogicalKeyboardKey shortcut;
  final bool isAlwaysOnTop;

  // Multi-Clip Specific
  final List<ClickPoint> points;
  final int currentPointIndex;
  final int multiClickDefaultDelayMs;

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
    this.liveX = 0,
    this.liveY = 0,
    this.shortcut = LogicalKeyboardKey.f6,
    this.actionType = ActionType.mouseClick,
    this.keyboardActionKey,
    this.useControl = false,
    this.useShift = false,
    this.useAlt = false,
    this.useCommand = false,
    this.points = const [],
    this.currentPointIndex = -1,
    this.multiClickDefaultDelayMs = 10000,
    this.isAlwaysOnTop = false,
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
    List<ClickPoint>? points,
    int? currentPointIndex,
    int? multiClickDefaultDelayMs,
    bool clearKeyboardAction = false,
    // Restored params
    ActionType? actionType,
    LogicalKeyboardKey? keyboardActionKey,
    bool? useControl,
    bool? useShift,
    bool? useAlt,
    bool? useCommand,
    double? liveX,
    double? liveY,
    LogicalKeyboardKey? shortcut,
    bool? isAlwaysOnTop,
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
      liveX: liveX ?? this.liveX,
      liveY: liveY ?? this.liveY,
      shortcut: shortcut ?? this.shortcut,
      points: points ?? this.points,
      currentPointIndex: currentPointIndex ?? this.currentPointIndex,
      multiClickDefaultDelayMs:
          multiClickDefaultDelayMs ?? this.multiClickDefaultDelayMs,
      isAlwaysOnTop: isAlwaysOnTop ?? this.isAlwaysOnTop,
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
  final Set<int> _heldKeys = {}; // Track held keys for safety release

  // Smart Recording State
  Timer? _clickCheckTimer;
  Timer? _dodgeTimer;
  Timer? _finalizeClickTimer;
  int _lastMask = 0;
  int _recordButton = 0;
  int _recordClickCount = 0;

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
      debugPrint('Error registering hotkey: $e');
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
    state = state.copyWith(isRunning: true);
    _runSequence();
  }

  Future<void> _executePoint(ClickPoint point) async {
    try {
      switch (point.type) {
        case ActionType.mouseClick:
          await _mouseService.performClick(
            x: point.x,
            y: point.y,
            button: point.mouseButton,
            clickCount: point.clickCount,
          );
          break;
        case ActionType.keyboard:
          if (point.key != null) {
            final code = _getNativeKeyCode(point.key!);
            if (code != null) {
              int repeats = point.clickCount.clamp(1, 999);
              for (int i = 0; i < repeats; i++) {
                switch (point.keyEventType) {
                  case KeyEventType.down:
                    await _mouseService.performKeyDown(code);
                    _heldKeys.add(code);
                    break;
                  case KeyEventType.up:
                    await _mouseService.performKeyUp(code);
                    _heldKeys.remove(code);
                    break;
                  case KeyEventType.press:
                    await _mouseService.performKeyPress(
                      code,
                      modifiers: point.modifiers,
                    );
                    break;
                }
                if (i < repeats - 1)
                  await Future.delayed(const Duration(milliseconds: 50));
              }
            }
          }
          break;
        case ActionType.text:
          if (point.text != null) {
            for (int i = 0; i < point.text!.length; i++) {
              final key = NativeKeyMapper.getLogicalKeyForChar(point.text![i]);
              if (key != null) {
                final code = _getNativeKeyCode(key);
                if (code != null) {
                  await _mouseService.performKeyPress(code);
                  if (i < point.text!.length - 1)
                    await Future.delayed(const Duration(milliseconds: 50));
                }
              }
            }
          }
          break;
        case ActionType.pause:
          // Just a placeholder for the delay that follows
          break;
        case ActionType.stop:
          await stop();
          break;
        case ActionType.loop:
          for (int i = 0; i < point.loopCount; i++) {
            for (final nested in point.nestedPoints) {
              if (!state.isRunning) return;
              await _executePoint(nested);
              await Future.delayed(Duration(milliseconds: nested.delayAfterMs));
            }
          }
          break;
      }
    } catch (e) {
      debugPrint("Error executing point: $e");
    }
    state = state.copyWith(clickCount: state.clickCount + 1);
  }

  Future<void> _runSequence() async {
    if (!state.isRunning) return;

    // --- GLOBAL KEYBOARD MODE ---
    if (state.actionType == ActionType.keyboard) {
      if (state.keyboardActionKey != null) {
        final code = _getNativeKeyCode(state.keyboardActionKey!);
        if (code != null) {
          await _mouseService.performKeyPress(
            code,
            modifiers: [
              if (state.useControl) 'control',
              if (state.useShift) 'shift',
              if (state.useAlt) 'alt',
              if (state.useCommand) 'meta',
            ],
          );
        }
      }
      state = state.copyWith(clickCount: state.clickCount + 1);
      if (state.isRunning) {
        int delay = state.totalIntervalMs;
        if (delay < 50) delay = 50;
        _timer = Timer(Duration(milliseconds: delay), _runSequence);
      }
      return;
    }

    // --- MULTI-CLIP SEQUENCE MODE ---
    if (state.points.isEmpty) {
      stop();
      return;
    }

    int idx = state.currentPointIndex;
    if (idx < 0 || idx >= state.points.length) idx = 0;

    state = state.copyWith(currentPointIndex: idx);
    final point = state.points[idx];

    await _executePoint(point);

    if (state.isRunning && point.type != ActionType.stop) {
      int delay = point.delayAfterMs;
      if (delay < 10) delay = 10;

      _timer = Timer(Duration(milliseconds: delay), () {
        int nextIdx = idx + 1;
        if (nextIdx >= state.points.length) {
          nextIdx = 0;
        }
        state = state.copyWith(currentPointIndex: nextIdx);
        _runSequence();
      });
    }
  }

  // --- Multi Clip Management ---

  void addPoint(ClickPoint point) {
    state = state.copyWith(points: [...state.points, point]);
  }

  void removePoint(String id) {
    state = state.copyWith(
      points: state.points.where((p) => p.id != id).toList(),
    );
  }

  void updatePoint(ClickPoint updatedPoint) {
    state = state.copyWith(
      points: state.points
          .map((p) => p.id == updatedPoint.id ? updatedPoint : p)
          .toList(),
    );
  }

  void reorderPoints(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final List<ClickPoint> items = List.from(state.points);
    final ClickPoint item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    state = state.copyWith(points: items);
  }

  void updateDefaultDelay(int ms) {
    state = state.copyWith(multiClickDefaultDelayMs: ms);
  }

  void updateActionType(ActionType type) {
    state = state.copyWith(actionType: type);
  }

  Future<void> updatePoints(List<ClickPoint> points) async {
    state = state.copyWith(points: points);
  }

  // --- Saved Sequences Logic ---

  Future<void> saveSequence(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final newSequence = SavedSequence(name: name, points: state.points);

    final savedList = await getSavedSequences();
    savedList.add(newSequence);

    final jsonList = savedList.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList('saved_sequences', jsonList);
  }

  Future<List<SavedSequence>> getSavedSequences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('saved_sequences') ?? [];
    return jsonList.map((j) => SavedSequence.fromJson(jsonDecode(j))).toList();
  }

  Future<void> loadSequence(SavedSequence sequence) async {
    // Deep copy points to ensure new IDs? Or keeps same?
    // It's safer to keep same properties but new IDs if we want them unique in session,
    // but typically loading means "restore this state".
    // For now, simple restore.
    state = state.copyWith(points: sequence.points);
  }

  Future<void> deleteSequence(String id) async {
    final prefs = await SharedPreferences.getInstance();
    var savedList = await getSavedSequences();
    savedList.removeWhere((s) => s.id == id);

    final jsonList = savedList.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList('saved_sequences', jsonList);
  }

  void updateKeyboardActionKey(LogicalKeyboardKey key) {
    state = state.copyWith(keyboardActionKey: key);
  }

  void toggleControl() => state = state.copyWith(useControl: !state.useControl);
  void toggleShift() => state = state.copyWith(useShift: !state.useShift);
  void toggleAlt() => state = state.copyWith(useAlt: !state.useAlt);
  void toggleCommand() => state = state.copyWith(useCommand: !state.useCommand);

  int? _getNativeKeyCode(LogicalKeyboardKey key) {
    return NativeKeyMapper.getNativeKeyCode(
      key,
      isMacOS: Platform.isMacOS,
      isWindows: Platform.isWindows,
    );
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);

    // Release all held keys
    for (final key in _heldKeys) {
      await _mouseService.performKeyUp(key);
    }
    _heldKeys.clear();
  }

  void updateTime({int? h, int? m, int? s, int? ms}) {
    state = state.copyWith(
      hours: h?.clamp(0, 999),
      minutes: m?.clamp(0, 59),
      seconds: s?.clamp(0, 59),
      milliseconds: ms?.clamp(0, 999),
    );
    // Sync default delay configuration as well
    updateDefaultDelay(state.totalIntervalMs);
  }

  // --- Preview Helpers ---
  Future<void> showPreview(double x, double y) async {
    await _mouseService.showPreview(x, y);
  }

  Future<void> hidePreview() async {
    await _mouseService.hidePreview();
  }

  Future<void> startPicking() async {
    state = state.copyWith(isPickingPosition: true);

    // Reset recording state
    _lastMask = 0;
    _recordButton = 0;
    _recordClickCount = 0;
    _finalizeClickTimer?.cancel();

    // Monitor for mouse clicks to save position automatically
    _clickCheckTimer = Timer.periodic(const Duration(milliseconds: 30), (
      timer,
    ) async {
      final int currentMask = await _mouseService.getPressedButtons();

      // Leading Edge (Down)
      if (currentMask > 0 && _lastMask == 0) {
        if (_finalizeClickTimer != null && _finalizeClickTimer!.isActive) {
          // Timer active means we are waiting for multi-click
          if (currentMask == _recordButton) {
            // Same button pressed again -> Increment count
            _recordClickCount++;
            _finalizeClickTimer!.cancel();
            // Feedback? Beep?
          } else {
            // Different button? Could finalize previous and start new,
            // but for simplicity, let's just ignore or reset.
            // Resetting for safety.
            _finalizeClickTimer!.cancel();
            _recordButton = currentMask;
            _recordClickCount = 1;
            debugPrint("Button changed during multi-click wait. Resetting.");
          }
        } else {
          // First click
          _recordButton = currentMask;
          _recordClickCount = 1;
        }
      }

      // Trailing Edge (Up)
      if (currentMask == 0 && _lastMask > 0) {
        // Released. specific button release logic might be complex with chords,
        // but assuming single button usage for now.

        // Start timer to verify if it's the end or user will click again
        _finalizeClickTimer = Timer(const Duration(milliseconds: 350), () {
          // Timeout reached -> Save the point
          endPicking(buttonMask: _recordButton, count: _recordClickCount);
        });
      }

      _lastMask = currentMask;
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

  void endPicking({int buttonMask = 1, int count = 1}) async {
    _dodgeTimer?.cancel();
    _dodgeTimer = null;
    _clickCheckTimer?.cancel();
    _clickCheckTimer = null;
    _finalizeClickTimer?.cancel();

    if (!state.isPickingPosition) return;

    final osPos = await _mouseService.getMousePosition();

    if (osPos != null) {
      String btnName = 'left';
      String nameSuffix = '';

      if (buttonMask == 2) btnName = 'right';
      if (buttonMask == 4) btnName = 'middle';

      if (btnName == 'right') {
        nameSuffix = ' (Derecho)';
      }

      if (count > 1) {
        nameSuffix += ' x$count';
      }

      // Add new point
      final newPoint = ClickPoint(
        x: osPos['x'],
        y: osPos['y'],
        name: "Punto ${state.points.length + 1}$nameSuffix",
        mouseButton: btnName,
        clickCount: count,
        delayAfterMs: state.multiClickDefaultDelayMs,
      );
      addPoint(newPoint);
      state = state.copyWith(isPickingPosition: false);
    } else {
      state = state.copyWith(isPickingPosition: false);
    }
  }

  void updateShowWelcome(bool show) {
    state = state.copyWith(showWelcome: show);
  }

  void toggleAlwaysOnTop() async {
    final newState = !state.isAlwaysOnTop;
    await windowManager.setAlwaysOnTop(newState);
    state = state.copyWith(isAlwaysOnTop: newState);
  }

  void clearPosition() {
    state = state.copyWith(points: []);
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
                    spacing: 5,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                        "PRO MULTI AUTO CLICKER",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white38,
                          letterSpacing: 4,
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
                      const SizedBox(height: 20),

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(30)),
                image: DecorationImage(
                  image: AssetImage('assets/images/logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
                _buildTitleBar(context, ref),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: const MultiClipManager(),
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

  Widget _buildTitleBar(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(clickSettingsProvider);
    final notifier = ref.read(clickSettingsProvider.notifier);

    return DragToMoveArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(5),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Row(
          spacing: 8,
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
            BuildMainButton(
              settings: settings,
              notifier: notifier,
              context: context,
            ),

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

            // Info Button
            IconButton(
              icon: const Icon(
                Icons.info_outline,
                size: 20,
                color: Colors.white54,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.black54,
                  builder: (ctx) => const InfoScreen(),
                );
              },
              tooltip: "Instrucciones",
            ),

            _buildAppsButton(),
            BuildStats(settings: settings),
            const SizedBox(width: 10),

            // Pin Button
            IconButton(
              icon: Icon(
                settings.isAlwaysOnTop
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
                size: 18,
                color: settings.isAlwaysOnTop
                    ? Colors.blueAccent
                    : Colors.white24,
              ),
              onPressed: notifier.toggleAlwaysOnTop,
              tooltip: settings.isAlwaysOnTop
                  ? "Desanclar ventana"
                  : "Fijar ventana encima",
            ),

            const SizedBox(width: 4),
            // Windows/custom style window controls
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 0,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.remove,
                    size: 18,
                    color: Colors.white54,
                  ),
                  onPressed: () async => await windowManager.minimize(),
                  tooltip: "Minimizar",
                ),
                IconButton(
                  icon: const Icon(
                    Icons.crop_square,
                    size: 18,
                    color: Colors.white54,
                  ),
                  onPressed: () async {
                    if (await windowManager.isMaximized()) {
                      await windowManager.unmaximize();
                    } else {
                      await windowManager.maximize();
                    }
                  },
                  tooltip: "Maximizar",
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => exit(0),
                  tooltip: "Cerrar",
                ),
              ],
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
}
