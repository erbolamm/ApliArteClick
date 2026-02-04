import 'package:apliarte_click/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuildStats extends StatefulWidget {
  const BuildStats({super.key, required this.settings});

  final ClickSettings settings;

  @override
  State<BuildStats> createState() => _BuildStatsState();
}

class _BuildStatsState extends State<BuildStats> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Column(
        children: [
          Text(
            "${widget.settings.clickCount}",
            style: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
            ),
          ),
          /* const Text(
            "ACCIONES",
            style: TextStyle(
              fontSize: 10,
              color: Colors.white38,
              letterSpacing: 1,
            ),
          ), */
        ],
      ),
    );
  }
}
