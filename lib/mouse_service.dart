import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart'; // Retained for FFI functions (calloc, free, ffi.sizeOf)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:win32/win32.dart';

/// ApliArte Mouse Service
/// Provides cross-platform mouse interaction capabilities.
abstract class MouseService {
  /// Performs a mouse click at the specified global coordinates (optional).
  Future<void> performClick({double? x, double? y});

  /// Checks if the application has the necessary permissions to control the mouse.
  Future<bool> checkPermissions();

  /// Retrieves the current global mouse cursor position.
  Future<Map<String, double>?> getMousePosition();

  /// Factory constructor to create the appropriate platform-specific implementation.
  static MouseService create() {
    if (Platform.isMacOS) {
      return _MacOSMouseService();
    } else if (Platform.isWindows) {
      return _WindowsMouseService();
    } else {
      return _GenericMouseService();
    }
  }
}

/// macOS implementation using MethodChannel to call native Swift code.
class _MacOSMouseService implements MouseService {
  static const _channel = MethodChannel('com.apliarte.click/mouse');

  @override
  Future<void> performClick({double? x, double? y}) async {
    try {
      await _channel.invokeMethod('performClick', {'x': x, 'y': y});
    } on PlatformException catch (e) {
      debugPrint("Failed to perform click: ${e.message}");
    }
  }

  @override
  Future<bool> checkPermissions() async {
    try {
      final bool? hasPermission = await _channel.invokeMethod(
        'checkPermissions',
      );
      return hasPermission ?? false;
    } on PlatformException catch (e) {
      debugPrint("Failed to check permissions: ${e.message}");
      return false;
    }
  }

  @override
  Future<Map<String, double>?> getMousePosition() async {
    try {
      final result = await _channel.invokeMapMethod<String, double>(
        'getMousePosition',
      );
      return result;
    } on PlatformException catch (e) {
      debugPrint("Failed to get mouse position: ${e.message}");
      return null;
    }
  }
}

/// Windows implementation using Win32 API directly via FFI.
class _WindowsMouseService implements MouseService {
  @override
  Future<void> performClick({double? x, double? y}) async {
    if (x != null && y != null) {
      // Set cursor position
      SetCursorPos(x.round(), y.round());
    }

    // Simulate mouse down and up
    final inputDown = calloc<INPUT>();
    inputDown.ref.type = INPUT_MOUSE;
    inputDown.ref.mi.dwFlags = MOUSEEVENTF_LEFTDOWN;
    SendInput(1, inputDown, ffi.sizeOf<INPUT>());
    free(inputDown);

    final inputUp = calloc<INPUT>();
    inputUp.ref.type = INPUT_MOUSE;
    inputUp.ref.mi.dwFlags = MOUSEEVENTF_LEFTUP;
    SendInput(1, inputUp, ffi.sizeOf<INPUT>());
    free(inputUp);
  }

  @override
  Future<bool> checkPermissions() async {
    // Windows doesn't require explicit accessibility permissions for SendInput typically
    return true;
  }

  @override
  Future<Map<String, double>?> getMousePosition() async {
    final point = calloc<POINT>();
    try {
      if (GetCursorPos(point) != 0) {
        return {'x': point.ref.x.toDouble(), 'y': point.ref.y.toDouble()};
      }
    } finally {
      free(point);
    }
    return null;
  }
}

class _GenericMouseService implements MouseService {
  @override
  Future<void> performClick({double? x, double? y}) async {
    debugPrint("Mouse clicking not implemented for this platform yet.");
  }

  @override
  Future<bool> checkPermissions() async {
    return true;
  }

  @override
  Future<Map<String, double>?> getMousePosition() async {
    return null;
  }
}
