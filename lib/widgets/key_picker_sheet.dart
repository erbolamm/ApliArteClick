import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/click_point.dart'; // Import ClickPoint model
import '../main.dart'; // Import for ActionType

class KeyPickerSheet extends StatefulWidget {
  final Function(LogicalKeyboardKey)? onKeySelected;
  final Function(List<ClickPoint>)? onKeysSelected; // Return ClickPoints
  final bool isActionKey;

  const KeyPickerSheet({
    super.key,
    this.onKeySelected,
    this.onKeysSelected,
    this.isActionKey = false,
  });

  @override
  State<KeyPickerSheet> createState() => _KeyPickerSheetState();
}

class _KeyPickerSheetState extends State<KeyPickerSheet> {
  final List<ClickPoint> _buffer = []; // Store ClickPoints directly
  bool _isComboMode = false;
  final Set<LogicalKeyboardKey> _physicallyHeldKeys = {};

  final List<LogicalKeyboardKey> _keys = [
    // Modifiers
    LogicalKeyboardKey.metaLeft, // Command
    LogicalKeyboardKey.controlLeft, // Control
    LogicalKeyboardKey.altLeft, // Option/Alt
    LogicalKeyboardKey.shiftLeft, // Shift
    LogicalKeyboardKey.fn, // Fn

    LogicalKeyboardKey.tab, // Separator
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.space,
    LogicalKeyboardKey.escape,
    LogicalKeyboardKey.backspace,
    LogicalKeyboardKey.delete,
    // Arrows
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    // Numbers
    LogicalKeyboardKey.digit0,
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
    LogicalKeyboardKey.digit6,
    LogicalKeyboardKey.digit7,
    LogicalKeyboardKey.digit8,
    LogicalKeyboardKey.digit9,
    // Letters
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyB,
    LogicalKeyboardKey.keyC,
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.keyE,
    LogicalKeyboardKey.keyF,
    LogicalKeyboardKey.keyG,
    LogicalKeyboardKey.keyH,
    LogicalKeyboardKey.keyI,
    LogicalKeyboardKey.keyJ,
    LogicalKeyboardKey.keyK,
    LogicalKeyboardKey.keyL,
    LogicalKeyboardKey.keyM,
    LogicalKeyboardKey.keyN,
    LogicalKeyboardKey.keyO,
    LogicalKeyboardKey.keyP,
    LogicalKeyboardKey.keyQ,
    LogicalKeyboardKey.keyR,
    LogicalKeyboardKey.keyS,
    LogicalKeyboardKey.keyT,
    LogicalKeyboardKey.keyU,
    LogicalKeyboardKey.keyV,
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.keyX,
    LogicalKeyboardKey.keyY,
    LogicalKeyboardKey.keyZ,
    // F-Keys
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

  String _getKeyLabel(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.space) {
      return "Espacio";
    }
    if (key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight) {
      return "Cmd ⌘";
    }
    if (key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight) {
      return "Ctrl ⌃";
    }
    if (key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight) {
      return "Alt ⌥";
    }
    if (key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight) {
      return "Shift ⇧";
    }
    if (key == LogicalKeyboardKey.enter) {
      return "Enter ⏎";
    }
    if (key == LogicalKeyboardKey.backspace) {
      return "Backspace ⌫";
    }
    if (key == LogicalKeyboardKey.escape) {
      return "Esc";
    }

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
        mods.add('meta');
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

  void _addKey(LogicalKeyboardKey key) {
    if (_isComboMode) {
      // --- COMBO MODE LOGIC ---
      if (_isModifier(key)) {
        // Modifiers just contribute to the combo state, don't add action yet
        return;
      }

      // It's a normal key. Combine with held modifiers.
      final mods = _getIdentifiersForHeldModifiers();

      String label = _getKeyLabel(key);
      if (mods.isNotEmpty) {
        // Create fancy label
        final modLabels = mods
            .map((m) {
              switch (m) {
                case 'meta':
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

      setState(() {
        _buffer.add(
          ClickPoint(
            key: key,
            type: ActionType.keyboard,
            keyEventType: KeyEventType.press,
            modifiers: mods,
            name: label,
            delayAfterMs: 100,
          ),
        );
      });
      return;
    }

    // --- SEQUENTIAL MODE LOGIC (Existing) ---
    setState(() {
      if (_isModifier(key)) {
        // Toggle logic: Check if last action for this key was DOWN
        // Find last occurrence of this key in buffer
        var lastEntryIndex = _buffer.lastIndexWhere(
          (p) => p.key?.keyId == key.keyId,
        );

      bool shouldRelease = false;
        if (lastEntryIndex != -1) {
          if (_buffer[lastEntryIndex].keyEventType == KeyEventType.down) {
            shouldRelease = true;
          }
        }

        if (shouldRelease) {
          _buffer.add(
            ClickPoint(
              key: key,
              type: ActionType.keyboard,
              keyEventType: KeyEventType.up,
              name: "Soltar ${_getKeyLabel(key)}",
            ),
          );
        } else {
          _buffer.add(
            ClickPoint(
              key: key,
              type: ActionType.keyboard,
              keyEventType: KeyEventType.down,
              name: "Sostener ${_getKeyLabel(key)}",
            ),
          );
        }
      } else {
        // Normal key press
        _buffer.add(
          ClickPoint(
            key: key,
            type: ActionType.keyboard,
            keyEventType: KeyEventType.press, // default
            name: "Tecla ${_getKeyLabel(key)}",
            delayAfterMs: 100, // Default delay for typing
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          _physicallyHeldKeys.add(event.logicalKey);
        } else if (event is KeyUpEvent) {
          _physicallyHeldKeys.remove(event.logicalKey);
        }

        if (event is KeyDownEvent) {
          // If pure modifier in combo mode, just consume it (it's tracked in _physicallyHeldKeys)
          if (_isComboMode && _isModifier(event.logicalKey)) {
            // Force UI update to show held keys? Not critical but good validation.
            setState(() {});
            return KeyEventResult.handled;
          }

          if (widget.isActionKey) {
            _addKey(event.logicalKey);
            return KeyEventResult.handled;
          } else {
            widget.onKeySelected?.call(event.logicalKey);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isActionKey
                      ? "CREAR SECUENCIA DE TECLAS"
                      : "SELECCIONA TECLA DE EMERGENCIA",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.isActionKey)
                  ElevatedButton.icon(
                    onPressed: _buffer.isEmpty
                        ? null
                        : () {
                            widget.onKeysSelected?.call(_buffer);
                          },
                    icon: const Icon(Icons.check, size: 18),
                    label: Text("LISTO (${_buffer.length})"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // --- MODE TOGGLE ---
            if (widget.isActionKey)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeButton("Secuencial 🎹", !_isComboMode, () {
                      setState(() => _isComboMode = false);
                    }),
                    const SizedBox(width: 5),
                    _buildModeButton("Combinado 🔗", _isComboMode, () {
                      setState(() => _isComboMode = true);
                    }),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // --- BUFFER DISPLAY ---
            if (widget.isActionKey)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: _buffer.isEmpty
                    ? const Center(
                        child: Text(
                          "Pulsa teclas para añadirlas...",
                          style: TextStyle(color: Colors.white38),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _buffer.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final point = entry.value;

                          Color chipColor;
                          if (point.keyEventType == KeyEventType.down) {
                            chipColor = Colors.redAccent.withAlpha(200);
                          } else if (point.keyEventType == KeyEventType.up) {
                            chipColor = Colors.orangeAccent.withAlpha(200);
                          } else {
                            chipColor = Colors.blueAccent.withAlpha(200);
                          }

                          return Chip(
                            label: Text(
                              point.name,
                            ), // Use point name which has "Sostener..."
                            backgroundColor: chipColor,
                            labelStyle: const TextStyle(color: Colors.white),
                            onDeleted: () {
                              setState(() {
                                _buffer.removeAt(idx);
                              });
                            },
                            deleteIcon: const Icon(Icons.close, size: 14),
                            deleteIconColor: Colors.white70,
                          );
                        }).toList(),
                      ),
              ),

            // --- KEYBOARD GRID ---
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  alignment: WrapAlignment.center,
                  children: _keys
                      .map(
                        (key) => ElevatedButton(
                          onPressed: () {
                            if (widget.isActionKey) {
                              _addKey(key);
                            } else {
                              widget.onKeySelected?.call(key);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withAlpha(10),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(_getKeyLabel(key)),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
