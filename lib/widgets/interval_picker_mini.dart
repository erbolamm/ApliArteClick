import 'package:flutter/material.dart';

class IntervalPickerMini extends StatelessWidget {
  final int hours;
  final int minutes;
  final int seconds;
  final int milliseconds;
  final Function(int, int, int, int) onChanged;

  const IntervalPickerMini({
    super.key,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.milliseconds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUnit(
            hours,
            "H",
            23,
            (val) => onChanged(val, minutes, seconds, milliseconds),
          ),
          _divider(),
          _buildUnit(
            minutes,
            "M",
            59,
            (val) => onChanged(hours, val, seconds, milliseconds),
          ),
          _divider(),
          _buildUnit(
            seconds,
            "S",
            59,
            (val) => onChanged(hours, minutes, val, milliseconds),
          ),
          _divider(),
          _buildUnit(
            milliseconds,
            "MS",
            9999,
            (val) => onChanged(hours, minutes, seconds, val),
            width: 30,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(":", style: TextStyle(color: Colors.white24, fontSize: 10)),
    );
  }

  Widget _buildUnit(
    int value,
    String label,
    int max,
    Function(int) onChange, {
    double width = 16,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 12,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 10,
            icon: const Icon(Icons.arrow_drop_up, color: Colors.white38),
            onPressed: () => onChange(value < max ? value + 1 : 0),
          ),
        ),
        SizedBox(
          width: width,
          child: Text(
            value.toString().padLeft(width > 20 ? 3 : 2, '0'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
        SizedBox(
          height: 12,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 10,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white38),
            onPressed: () => onChange(value > 0 ? value - 1 : max),
          ),
        ),
      ],
    );
  }
}
