/* import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';

class OverlayService {
  static final OverlayService _instance = OverlayService._internal();
  factory OverlayService() => _instance;
  OverlayService._internal();

  int? _overlayWindowId;
  bool _isOverlayRunning = false;

  /// Spawns the overlay window if not already running.
  Future<void> startOverlay() async {
    if (_isOverlayRunning) return;

    try {
      final window = await DesktopMultiWindow.createWindow(
        jsonEncode({'args1': 'overlay_init'}),
      );
      _overlayWindowId = window.windowId;
      _isOverlayRunning = true;
      debugPrint("Overlay Window Spawned: ID=$_overlayWindowId");

      // Optionally resize it immediately if needed, but the overlay code handles fullscreen?
      // Actually overlay logic in overlay_main.dart handles windowManager.waitUntilReadyToShow
      // with standard "transparent" options.
      // But we might want to force it to cover all screens here using ScreenRetriever later.
      // For now, let the overlay set itself up.
    } catch (e) {
      debugPrint("Error starting overlay: $e");
    }
  }

  /// Sends coordinate updates to the overlay
  Future<void> updateCursor(double x, double y, {bool visible = true}) async {
    if (_overlayWindowId == null) return;
    try {
      await DesktopMultiWindow.invokeMethod(
        _overlayWindowId!,
        "updatePreview",
        {"x": x, "y": y, "visible": visible},
      );
    } catch (e) {
      debugPrint("Error sending cursor update: $e");
    }
  }

  /// Hides the cursor in the overlay
  Future<void> hideCursor() async {
    if (_overlayWindowId == null) return;
    try {
      await DesktopMultiWindow.invokeMethod(
        _overlayWindowId!,
        "updatePreview",
        {"visible": false},
      );
    } catch (e) {
      // Ignore errors if window closed
    }
  }

  /// Triggers the pulse animation
  Future<void> showPulse() async {
    if (_overlayWindowId == null) return;
    try {
      await DesktopMultiWindow.invokeMethod(_overlayWindowId!, "pulse");
    } catch (e) {
      // Ignore
    }
  }
}
 */