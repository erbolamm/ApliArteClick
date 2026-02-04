import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntervalPicker extends StatelessWidget {
  final int hours;
  final int minutes;
  final int seconds;
  final int milliseconds;
  final Function(int h, int m, int s, int ms) onChanged;
  final String title;

  const IntervalPicker({
    super.key,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.milliseconds,
    required this.onChanged,
    this.title = "INTERVAL REPEAT",
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 3,
          runSpacing: 3,
          children: [
            _buildTimeUnit("H", hours, (v) => _update(h: hours + v)),
            _buildTimeUnit("M", minutes, (v) => _update(m: minutes + v)),
            _buildTimeUnit("S", seconds, (v) => _update(s: seconds + v)),
            _buildTimeUnit(
              "MS",
              milliseconds,
              (v) => _update(ms: milliseconds + (v * 10)),
              step: 10,
            ),
          ],
        ),
      ],
    );
  }

  void _update({int? h, int? m, int? s, int? ms}) {
    // Normalize values if needed, or just pass them through
    // For now assuming the parent handles strict validation if needed,
    // but typical rollover logic (60s -> 1m) isn't strictly enforced in the original code,
    // it just increments the specific unit. We'll keep that behavior.

    // Ensure non-negative
    final nh = (h ?? hours).clamp(0, 999);
    final nm = (m ?? minutes).clamp(0, 59);
    final ns = (s ?? seconds).clamp(0, 59);
    final nms = (ms ?? milliseconds).clamp(0, 990);

    onChanged(nh, nm, ns, nms);
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
                  color: Colors.white,
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
}
