import 'package:flutter/material.dart';
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
    return Container(
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
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.library_books, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Text(
                  "Mis Acciones",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10),
          Expanded(child: _MyActionsTab(onSelected: onSelected)),
        ],
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
                        (context as Element).markNeedsBuild();
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
