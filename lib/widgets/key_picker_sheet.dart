import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/click_point.dart'; // Import ClickPoint model
import '../main.dart'; // Import for ActionType

class KeyPickerSheet extends StatefulWidget {
  final Function(LogicalKeyboardKey)? onKeySelected;
  final Function(List<ClickPoint>)? onKeysSelected; // Return ClickPoints
  final bool isActionKey;
  final int defaultDelayMs;

  const KeyPickerSheet({
    super.key,
    this.onKeySelected,
    this.onKeysSelected,
    this.isActionKey = false,
    this.defaultDelayMs = 1000,
  });

  @override
  State<KeyPickerSheet> createState() => _KeyPickerSheetState();
}

class _KeyPickerSheetState extends State<KeyPickerSheet> {
  // Store the single consolidated shortcut point
  ClickPoint? _recordedPoint;

  // Track physically held keys for visualization
  final Set<LogicalKeyboardKey> _physicallyHeldKeys = {};

  // To allow "Composing" a complex shortcut without triggering immediately?
  // User wants: Press keys -> See them -> Confirm.

  String _getKeyLabel(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.space) return "Espacio";
    if (key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight)
      return "Cmd ⌘";
    if (key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight)
      return "Ctrl ⌃";
    if (key == LogicalKeyboardKey.altLeft || key == LogicalKeyboardKey.altRight)
      return "Alt ⌥";
    if (key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight)
      return "Shift ⇧";
    if (key == LogicalKeyboardKey.enter) return "Enter ⏎";
    if (key == LogicalKeyboardKey.backspace) return "Backspace ⌫";
    if (key == LogicalKeyboardKey.escape) return "Esc";
    if (key == LogicalKeyboardKey.tab) return "Tab ⇥";
    if (key == LogicalKeyboardKey.arrowUp) return "↑";
    if (key == LogicalKeyboardKey.arrowDown) return "↓";
    if (key == LogicalKeyboardKey.arrowLeft) return "←";
    if (key == LogicalKeyboardKey.arrowRight) return "→";

    return key.keyLabel;
  }

  bool _isModifier(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight ||
        key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.fn;
  }

  List<String> _getIdentifiersForHeldModifiers() {
    List<String> mods = [];
    for (final key in _physicallyHeldKeys) {
      if (key == LogicalKeyboardKey.metaLeft ||
          key == LogicalKeyboardKey.metaRight)
        mods.add('command');
      if (key == LogicalKeyboardKey.controlLeft ||
          key == LogicalKeyboardKey.controlRight)
        mods.add('control');
      if (key == LogicalKeyboardKey.altLeft ||
          key == LogicalKeyboardKey.altRight)
        mods.add('alt');
      if (key == LogicalKeyboardKey.shiftLeft ||
          key == LogicalKeyboardKey.shiftRight)
        mods.add('shift');
    }
    return mods.toSet().toList(); // Unique
  }

  void _processKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      setState(() {
        _physicallyHeldKeys.add(event.logicalKey);
      });

      // If it's NOT a modifier, it's the "trigger" key of the shortcut
      if (!_isModifier(event.logicalKey)) {
        _captureShortcut(event.logicalKey);
      }
    } else if (event is KeyUpEvent) {
      setState(() {
        _physicallyHeldKeys.remove(event.logicalKey);
      });
    }
  }

  void _captureShortcut(LogicalKeyboardKey triggerKey) {
    // 1. Rename modifiers for the model
    final mods = _getIdentifiersForHeldModifiers();

    // 2. Build display name
    String label = _getKeyLabel(triggerKey);
    if (mods.isNotEmpty) {
      final modLabels = mods
          .map((m) {
            switch (m) {
              case 'command':
                return 'Cmd';
              case 'control':
                return 'Ctrl';
              case 'alt':
                return 'Alt';
              case 'shift':
                return 'Shift';
              default:
                return m;
            }
          })
          .join(" + ");
      label = "$modLabels + $label";
    }

    // 3. Create the point
    setState(() {
      _recordedPoint = ClickPoint(
        key: triggerKey,
        type: ActionType.keyboard,
        keyEventType: KeyEventType.press, // Always press for shortcuts
        modifiers: mods,
        name: "Atajo: $label",
        delayAfterMs: widget.defaultDelayMs,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        _processKeyEvent(event);
        return KeyEventResult.handled;
      },
      child: Container(
        padding: const EdgeInsets.all(30),
        height: 400, // Reduced height since we don't need the grid
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "GRABAR ATAJO / TECLA",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),

            const Spacer(),

            // Visualization Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _recordedPoint != null
                      ? Colors.greenAccent.withOpacity(0.5)
                      : Colors.white12,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  if (_recordedPoint == null) ...[
                    const Icon(
                      Icons.keyboard_outlined,
                      size: 60,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Presiona tu combinación de teclas...",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                    // Show held keys live preview
                    if (_physicallyHeldKeys.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        children: _physicallyHeldKeys.map((k) {
                          return Chip(
                            label: Text(_getKeyLabel(k)),
                            backgroundColor: Colors.blueAccent.withOpacity(0.3),
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ] else ...[
                    const Icon(
                      Icons.check_circle_outline,
                      size: 60,
                      color: Colors.greenAccent,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _recordedPoint!.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "¿Es correcto?",
                      style: TextStyle(color: Colors.white38),
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_recordedPoint != null) ...[
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _recordedPoint = null;
                        _physicallyHeldKeys.clear();
                      });
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white60),
                    label: const Text(
                      "REINTENTAR",
                      style: TextStyle(color: Colors.white60),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (widget.isActionKey && widget.onKeysSelected != null) {
                        // Wrap in list as per old contract, but now it's just one consolidated point
                        widget.onKeysSelected!([_recordedPoint!]);
                      } else if (widget.onKeySelected != null &&
                          _recordedPoint!.key != null) {
                        // Fallback for single key usage (e.g. stop key)
                        // But stop key doesn't use modifiers usually.
                        widget.onKeySelected!(_recordedPoint!.key!);
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("CONFIRMAR"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
