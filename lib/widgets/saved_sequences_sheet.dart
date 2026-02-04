import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/click_point.dart';
import '../models/saved_sequence.dart';

class ActionLibrarySheet extends ConsumerWidget {
  final Function(List<ClickPoint>) onSelected;

  const ActionLibrarySheet({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 10),
            TabBar(
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              tabs: const [
                Tab(text: "Mis Acciones"),
                Tab(text: "Predefinidas 🎁"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _MyActionsTab(onSelected: onSelected),
                  _PresetsTab(onSelected: onSelected),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyActionsTab extends ConsumerWidget {
  final Function(List<ClickPoint>) onSelected;

  const _MyActionsTab({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(clickSettingsProvider.notifier);
    // accessing future provider or state... in original code it was getSavedSequences() which returns Future
    // We need to handle that. Ideally the notifier exposes the list in state, but simpler to use FutureBuilder or similar
    // if the original code was doing `await notifier.getSavedSequences()`.
    // Let's assume we can call it.

    return FutureBuilder<List<SavedSequence>>(
      future: notifier.getSavedSequences(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final sequences = snapshot.data!;

        if (sequences.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder_open, size: 48, color: Colors.white12),
                const SizedBox(height: 10),
                Text(
                  "No tienes acciones guardadas",
                  style: GoogleFonts.outfit(color: Colors.white38),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sequences.length,
          itemBuilder: (context, index) {
            final seq = sequences[index];
            return Card(
              color: Colors.white.withAlpha(10),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.bookmark, color: Colors.purpleAccent),
                title: Text(
                  seq.name,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  "${seq.points.length} pasos",
                  style: const TextStyle(color: Colors.white54),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.white24,
                        size: 20,
                      ),
                      onPressed: () async {
                        await notifier.deleteSequence(seq.id);
                        (context as Element)
                            .markNeedsBuild(); // Force rebuild hack or use proper state
                      },
                    ),
                    const Icon(Icons.add_circle, color: Colors.blueAccent),
                  ],
                ),
                onTap: () => onSelected(seq.points),
              ),
            );
          },
        );
      },
    );
  }
}

class _PresetsTab extends StatelessWidget {
  final Function(List<ClickPoint>) onSelected;

  const _PresetsTab({required this.onSelected});

  // Generating presets on the fly
  List<SavedSequence> get presets => [
    SavedSequence(
      name: "Cambiar App (Mac)",
      points: [
        ClickPoint(
          key: LogicalKeyboardKey.metaLeft,
          type: ActionType.keyboard,
          keyEventType: KeyEventType.down,
          name: "Sostener Cmd",
        ),
        ClickPoint(
          key: LogicalKeyboardKey.tab,
          type: ActionType.keyboard,
          keyEventType: KeyEventType.press,
          name: "Tecla Tab",
          delayAfterMs: 200,
        ),
        ClickPoint(
          key: LogicalKeyboardKey.metaLeft,
          type: ActionType.keyboard,
          keyEventType: KeyEventType.up,
          name: "Soltar Cmd",
        ),
      ],
    ),
    SavedSequence(
      name: "Copiar (Cmd+C)",
      points: [
        ClickPoint(
          key: LogicalKeyboardKey.keyC,
          type: ActionType.keyboard,
          keyEventType: KeyEventType.press,
          modifiers: ['meta'],
          name: "Cmd + C",
        ),
      ],
    ),
    SavedSequence(
      name: "Pegar (Cmd+V)",
      points: [
        ClickPoint(
          key: LogicalKeyboardKey.keyV,
          type: ActionType.keyboard,
          keyEventType: KeyEventType.press,
          modifiers: ['meta'],
          name: "Cmd + V",
        ),
      ],
    ),
    SavedSequence(
      name: "Cerrar Ventana (Cmd+W)",
      points: [
        ClickPoint(
          key: LogicalKeyboardKey.keyW,
          type: ActionType.keyboard,
          keyEventType: KeyEventType.press,
          modifiers: ['meta'],
          name: "Cmd + W",
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: presets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final seq = presets[index];
        return ListTile(
          tileColor: Colors.white.withAlpha(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: const Icon(Icons.star, color: Colors.orangeAccent),
          title: Text(seq.name, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            seq.points.map((p) => p.name).join(" → "),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          trailing: const Icon(Icons.add_circle, color: Colors.greenAccent),
          onTap: () => onSelected(seq.points),
        );
      },
    );
  }
}
