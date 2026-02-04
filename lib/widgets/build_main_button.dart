import 'package:apliarte_click/main.dart';
import 'package:flutter/material.dart';

class BuildMainButton extends StatefulWidget {
  const BuildMainButton({
    super.key,
    required this.settings,
    required this.notifier,
    required this.context,
  });

  final ClickSettings settings;
  final ClickSettingsNotifier notifier;
  final BuildContext context;

  @override
  State<BuildMainButton> createState() => _BuildMainButtonState();
}

class _BuildMainButtonState extends State<BuildMainButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.notifier.toggleClicking(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        //height: 60, // Reduced from 80
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // Slightly smaller radius
          gradient: LinearGradient(
            colors: widget.settings.isRunning
                ? [Colors.redAccent, Colors.red.shade900]
                : [Colors.blueAccent, Colors.blue.shade900],
          ),
          boxShadow: [
            BoxShadow(
              color:
                  (widget.settings.isRunning
                          ? Colors.redAccent
                          : Colors.blueAccent)
                      .withAlpha(100),
              blurRadius: 20, // Slightly reduced blur
              spreadRadius: -2,
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              widget.settings.isRunning ? Icons.stop : Icons.play_arrow,
              size: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
