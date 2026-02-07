import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/click_point.dart';
import 'interval_picker_mini.dart';
import 'key_picker_sheet.dart';
import 'saved_sequences_sheet.dart';

class MultiClipManager extends ConsumerWidget {
  const MultiClipManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(clickSettingsProvider);
    final notifier = ref.read(clickSettingsProvider.notifier);
    final points = settings.points;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- HEADER CONTROLS ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              // Interval Picker Mini
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "INTERVALO",
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.white38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  IntervalPickerMini(
                    hours: settings.hours,
                    minutes: settings.minutes,
                    seconds: settings.seconds,
                    milliseconds: settings.milliseconds,
                    onChanged: (h, m, s, ms) =>
                        notifier.updateTime(h: h, m: m, s: s, ms: ms),
                  ),
                ],
              ),

              Container(
                height: 30,
                width: 1,
                color: Colors.white12,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),

              // Stop Shortcut Mini
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "PARAR CON TECLA",
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.white38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => _showShortcutPicker(context, ref),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blueAccent.withAlpha(50),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.keyboard,
                              size: 14,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              settings.shortcut.keyLabel,
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              IconButton(
                onPressed: () => _showSavedSequencesDialog(context, ref),
                icon: const Icon(Icons.folder_open, color: Colors.orangeAccent),
                tooltip: "Biblioteca (Mis Acciones / Predefinidas)",
                style: IconButton.styleFrom(backgroundColor: Colors.white10),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showSaveDialog(context, ref),
                icon: const Icon(Icons.save, color: Colors.purpleAccent),
                tooltip: "Guardar Secuencia",
                style: IconButton.styleFrom(backgroundColor: Colors.white10),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _addNewPoint(context, ref),
                icon: const Icon(Icons.add, color: Colors.blueAccent),
                tooltip: "Añadir Acción",
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blueAccent.withAlpha(30),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Text(
          "Secuencia de Acciones",
          style: GoogleFonts.outfit(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: points.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.touch_app,
                          color: Colors.white24,
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "No hay puntos configurados",
                          style: TextStyle(color: Colors.white38),
                        ),
                        TextButton(
                          onPressed: () => _addNewPoint(context, ref),
                          child: const Text("Añadir el primero"),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: points.length,
                    onReorder: (oldIndex, newIndex) {
                      notifier.reorderPoints(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final point = points[index];
                      final isCurrent =
                          index == settings.currentPointIndex &&
                          settings.isRunning;
                      return _buildPointItem(
                        context,
                        ref,
                        point,
                        index,
                        isCurrent,
                      );
                    },
                  ),
          ),
        ),
        if (settings.isPickingPosition)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withAlpha(50),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueAccent.withAlpha(100)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.radar, color: Colors.blueAccent, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Haz clic en cualquier lugar para guardar el nuevo punto...",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPointItem(
    BuildContext context,
    WidgetRef ref,
    ClickPoint point,
    int index,
    bool isCurrent,
  ) {
    Color titleColor = Colors.white;
    Color iconBgColor = Colors.white10;
    IconData icon;
    Color iconColor = Colors.white;

    switch (point.type) {
      case ActionType.keyboard:
        icon = Icons.keyboard;
        break;
      case ActionType.text:
        icon = Icons.text_fields;
        break;
      case ActionType.pause:
        icon = Icons.timer_outlined;
        iconColor = Colors.yellowAccent;
        break;
      case ActionType.stop:
        icon = Icons.stop_circle_outlined;
        iconColor = Colors.redAccent;
        break;
      case ActionType.loop:
        icon = Icons.loop;
        iconColor = Colors.cyanAccent;
        break;
      default:
        icon = Icons.touch_app;
    }

    if (point.keyEventType == KeyEventType.down) {
      titleColor = Colors.redAccent;
      iconBgColor = Colors.redAccent.withAlpha(50);
    } else if (point.keyEventType == KeyEventType.up) {
      titleColor = Colors.orangeAccent;
      iconBgColor = Colors.orangeAccent.withAlpha(50);
    }

    final String subtitle;
    switch (point.type) {
      case ActionType.text:
        subtitle = 'Texto: "${point.text}" • Espera: ${point.delayAfterMs}ms';
        break;
      case ActionType.keyboard:
        String keyDisplay = point.key?.keyLabel ?? 'Tecla';
        // Add modifiers to the display
        if (point.modifiers.isNotEmpty) {
          final modLabels = point.modifiers
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
              .join(' + ');
          keyDisplay = '$modLabels + $keyDisplay';
        }
        subtitle =
            'Tecla: $keyDisplay${point.clickCount > 1 ? " (x${point.clickCount})" : ""} • Espera: ${point.delayAfterMs}ms';
        break;
      case ActionType.pause:
        subtitle = 'Esperar ${point.delayAfterMs}ms sin hacer nada';
        break;
      case ActionType.stop:
        subtitle = 'Finaliza la ejecución de la secuencia';
        break;
      case ActionType.loop:
        subtitle =
            'Repites ${point.loopCount} veces (${point.nestedPoints.length} acciones dentro)';
        break;
      default:
        subtitle =
            '[${point.x?.toInt() ?? 0}, ${point.y?.toInt() ?? 0}] • Espera: ${point.delayAfterMs}ms';
    }

    final Widget itemContent = Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrent
            ? Colors.green.withAlpha(50)
            : Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isCurrent ? Colors.green : Colors.white12),
      ),
      child: Column(
        children: [
          ListTile(
            dense: true,
            leading: DragTarget<String>(
              onWillAccept: (data) =>
                  point.type == ActionType.loop && data != point.id,
              onAccept: (draggedId) {
                _moveActionToLoop(ref, draggedId, point.id);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? Colors.cyanAccent.withAlpha(100)
                        : iconBgColor,
                    shape: BoxShape.circle,
                    border: candidateData.isNotEmpty
                        ? Border.all(color: Colors.cyanAccent)
                        : null,
                  ),
                  child: point.type == ActionType.mouseClick
                      ? Text(
                          "${index + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )
                      : Icon(icon, size: 16, color: iconColor),
                );
              },
            ),
            title: Text(
              point.name,
              style: TextStyle(color: titleColor, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.white54),
                  onPressed: () => _editPoint(context, ref, point),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    ref
                        .read(clickSettingsProvider.notifier)
                        .removePoint(point.id);
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          if (point.type == ActionType.loop && point.nestedPoints.isNotEmpty)
            Container(
              padding: const EdgeInsets.only(left: 32, right: 8, bottom: 8),
              child: Column(
                children: point.nestedPoints.asMap().entries.map((entry) {
                  final nested = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getIconForAction(nested.type),
                          size: 12,
                          color: Colors.white38,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            nested.name,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white24,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () =>
                              _removeNestedPoint(ref, point.id, nested.id),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );

    return MouseRegion(
      key: ValueKey(point.id),
      onEnter: (_) {
        if (point.x != null && point.y != null) {
          ref
              .read(clickSettingsProvider.notifier)
              .showPreview(point.x!, point.y!);
        }
      },
      onExit: (_) {
        ref.read(clickSettingsProvider.notifier).hidePreview();
      },
      child: Draggable<String>(
        data: point.id,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withAlpha(200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              point.name,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        child: itemContent,
      ),
    );
  }

  IconData _getIconForAction(ActionType type) {
    switch (type) {
      case ActionType.keyboard:
        return Icons.keyboard;
      case ActionType.text:
        return Icons.text_fields;
      case ActionType.pause:
        return Icons.timer_outlined;
      case ActionType.stop:
        return Icons.stop_circle_outlined;
      case ActionType.loop:
        return Icons.loop;
      default:
        return Icons.touch_app;
    }
  }

  void _moveActionToLoop(WidgetRef ref, String draggedId, String loopId) {
    final notifier = ref.read(clickSettingsProvider.notifier);
    final settings = ref.read(clickSettingsProvider);

    // Find the dragged point
    ClickPoint? dragged;
    try {
      dragged = settings.points.firstWhere((p) => p.id == draggedId);
    } catch (_) {
      // Maybe it's already in a loop? (Future scope: nested loops)
      return;
    }

    // Find the loop point
    final loopIdx = settings.points.indexWhere((p) => p.id == loopId);
    if (loopIdx == -1) return;
    final loop = settings.points[loopIdx];

    // 1. Remove from main list
    notifier.removePoint(draggedId);

    // 2. Add to loop's nestedPoints
    final updatedLoop = loop.copyWith(
      nestedPoints: [...loop.nestedPoints, dragged],
    );
    notifier.updatePoint(updatedLoop);
  }

  void _removeNestedPoint(WidgetRef ref, String loopId, String nestedId) {
    final notifier = ref.read(clickSettingsProvider.notifier);
    final settings = ref.read(clickSettingsProvider);

    final loopIdx = settings.points.indexWhere((p) => p.id == loopId);
    if (loopIdx == -1) return;
    final loop = settings.points[loopIdx];

    final updatedLoop = loop.copyWith(
      nestedPoints: loop.nestedPoints.where((p) => p.id != nestedId).toList(),
    );
    notifier.updatePoint(updatedLoop);

    // Optional: Add it back to main list? The user might just want to delete it.
    // For now, let's just delete it from the loop.
  }

  void _addNewPoint(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          "Tipo de Acción",
          style: TextStyle(color: Colors.white),
        ),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _startMousePicking(ref);
            },
            child: const Row(
              children: [
                Icon(Icons.mouse, color: Colors.blueAccent),
                SizedBox(width: 10),
                Text("Click de Ratón", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _pickKeyForNewPoint(context, ref);
            },
            child: const Row(
              children: [
                Icon(Icons.keyboard, color: Colors.greenAccent),
                SizedBox(width: 10),
                Text("Tecla / Atajo", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _pickTextForNewPoint(context, ref);
            },
            child: const Row(
              children: [
                Icon(Icons.text_fields, color: Colors.orangeAccent),
                SizedBox(width: 10),
                Text("Escribir Texto", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const Divider(color: Colors.white12),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _addPausePoint(ref);
            },
            child: const Row(
              children: [
                Icon(Icons.timer_outlined, color: Colors.yellowAccent),
                SizedBox(width: 10),
                Text("Pausa (Espera)", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _addStopPoint(ref);
            },
            child: const Row(
              children: [
                Icon(Icons.stop_circle_outlined, color: Colors.redAccent),
                SizedBox(width: 10),
                Text("Parar Secuencia", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _addLoopPoint(ref);
            },
            child: const Row(
              children: [
                Icon(Icons.loop, color: Colors.cyanAccent),
                SizedBox(width: 10),
                Text("Bucle (Grupo)", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addPausePoint(WidgetRef ref) {
    ref
        .read(clickSettingsProvider.notifier)
        .addPoint(
          ClickPoint(
            name: "Pausa",
            type: ActionType.pause,
            delayAfterMs: 2000, // Default 2s pause
          ),
        );
  }

  void _addStopPoint(WidgetRef ref) {
    ref
        .read(clickSettingsProvider.notifier)
        .addPoint(ClickPoint(name: "Parar", type: ActionType.stop));
  }

  void _addLoopPoint(WidgetRef ref) {
    ref
        .read(clickSettingsProvider.notifier)
        .addPoint(
          ClickPoint(
            name: "Bucle",
            type: ActionType.loop,
            loopCount: 2,
            nestedPoints: [],
          ),
        );
  }

  void _startMousePicking(WidgetRef ref) {
    ref.read(clickSettingsProvider.notifier).startPicking();
  }

  void _pickKeyForNewPoint(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final settings = ref.read(clickSettingsProvider);
        final defaultDelay =
            (settings.hours * 3600000) +
            (settings.minutes * 60000) +
            (settings.seconds * 1000) +
            settings.milliseconds;

        return KeyPickerSheet(
          isActionKey: true, // Use full list
          defaultDelayMs: defaultDelay > 0 ? defaultDelay : 1000,
          onKeysSelected: (points) {
            final notifier = ref.read(clickSettingsProvider.notifier);
            for (final point in points) {
              // Points from KeyPickerSheet are already configured with key, type, etc.
              // We just need to add them. They might not have unique IDs yet if ClickPoint constructor generates one?
              // ClickPoint constructor generates UUID by default if not provided.
              notifier.addPoint(point);
            }
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _pickTextForNewPoint(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          "Escribir Texto",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Texto a escribir",
            hintText: "Ej. Hola Mundo",
            labelStyle: TextStyle(color: Colors.white54),
            hintStyle: TextStyle(color: Colors.white24),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                ref
                    .read(clickSettingsProvider.notifier)
                    .addPoint(
                      ClickPoint(
                        name: 'Escribir "${textController.text}"',
                        type: ActionType.text,
                        text: textController.text,
                        // Default delay for typed text
                        delayAfterMs: 1000,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text("AÑADIR"),
          ),
        ],
      ),
    );
  }

  void _editPoint(BuildContext context, WidgetRef ref, ClickPoint point) {
    showDialog(
      context: context,
      builder: (ctx) => _EditPointDialog(point: point),
    );
  }

  void _showSaveDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          "Guardar Secuencia",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Nombre de la secuencia",
            hintText: "Ej. Combo Farming",
            labelStyle: TextStyle(color: Colors.white54),
            hintStyle: TextStyle(color: Colors.white24),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(clickSettingsProvider.notifier)
                    .saveSequence(controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Secuencia guardada con éxito")),
                );
              }
            },
            child: const Text("GUARDAR"),
          ),
        ],
      ),
    );
  }

  void _showSavedSequencesDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ActionLibrarySheet(
        onSelected: (points) {
          final notifier = ref.read(clickSettingsProvider.notifier);
          // Add points with NEW IDs to avoid conflicts
          for (final point in points) {
            notifier.addPoint(
              ClickPoint(
                name: point.name,
                type: point.type,
                x: point.x,
                y: point.y,
                delayAfterMs: point.delayAfterMs,
                key: point.key,
                modifiers: point.modifiers,
                keyEventType: point.keyEventType,
                // id: null -> Generates new UUID
              ),
            );
          }
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${points.length} acciones importadas"),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  void _showShortcutPicker(
    BuildContext context,
    WidgetRef ref, {
    bool isActionKey = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => KeyPickerSheet(
        isActionKey: isActionKey,
        onKeySelected: (key) {
          final notifier = ref.read(clickSettingsProvider.notifier);
          if (isActionKey) {
            notifier.updateKeyboardActionKey(key);
          } else {
            notifier.updateShortcut(key);
          }
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _EditPointDialog extends ConsumerStatefulWidget {
  final ClickPoint point;

  const _EditPointDialog({required this.point});

  @override
  ConsumerState<_EditPointDialog> createState() => _EditPointDialogState();
}

class _EditPointDialogState extends ConsumerState<_EditPointDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _textCtrl;
  late TextEditingController _loopCtrl;
  LogicalKeyboardKey? selectedKey;

  late int h;
  late int m;
  late int s;
  late int ms;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.point.name);
    _textCtrl = TextEditingController(text: widget.point.text ?? '');
    _loopCtrl = TextEditingController(text: widget.point.loopCount.toString());
    selectedKey = widget.point.key;

    int totalMs = widget.point.delayAfterMs;
    int secs = totalMs ~/ 1000;
    ms = totalMs % 1000;
    int mins = secs ~/ 60;
    s = secs % 60;
    h = mins ~/ 60;
    m = mins % 60;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black87,
      title: const Text("Editar Punto", style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.point.type == ActionType.keyboard) ...[
              const Text(
                "Tecla Asignada",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                icon: const Icon(Icons.keyboard),
                label: Text(widget.point.key?.keyLabel ?? "Seleccionar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.grey.shade900,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => KeyPickerSheet(
                      isActionKey: true,
                      onKeySelected: (key) {
                        setState(() {
                          selectedKey = key;
                          _nameCtrl.text = "Tecla ${key.keyLabel}";
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
            if (widget.point.type == ActionType.text) ...[
              TextField(
                controller: _textCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Texto a escribir",
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                ),
                onChanged: (val) {
                  // Auto-update name if it was default
                  if (_nameCtrl.text.startsWith('Escribir "')) {
                    _nameCtrl.text = 'Escribir "$val"';
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
            if (widget.point.type == ActionType.loop) ...[
              TextField(
                controller: _loopCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Repeticiones",
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            const Text(
              "ESPERA DESPUÉS (ms)",
              style: TextStyle(color: Colors.white54, fontSize: 10),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildTimePicker("H", h, (v) => setState(() => h = v)),
                _buildTimePicker("M", m, (v) => setState(() => m = v)),
                _buildTimePicker("S", s, (v) => setState(() => s = v)),
                _buildTimePicker("MS", ms, (v) => setState(() => ms = v)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("CANCELAR"),
        ),
        ElevatedButton(
          onPressed: () {
            final totalMs = (h * 3600000) + (m * 60000) + (s * 1000) + ms;
            final updated = widget.point.copyWith(
              name: _nameCtrl.text,
              text: widget.point.type == ActionType.text
                  ? _textCtrl.text
                  : widget.point.text,
              delayAfterMs: totalMs,
              key: selectedKey,
              loopCount: int.tryParse(_loopCtrl.text) ?? 1,
            );
            ref.read(clickSettingsProvider.notifier).updatePoint(updated);
            Navigator.pop(context);
          },
          child: const Text("GUARDAR"),
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, int value, Function(int) onChanged) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
          TextField(
            controller: TextEditingController(text: value.toString())
              ..selection = TextSelection.collapsed(
                offset: value.toString().length,
              ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white10),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
            ),
            onChanged: (val) {
              final n = int.tryParse(val) ?? 0;
              onChanged(n);
            },
          ),
        ],
      ),
    );
  }
}
