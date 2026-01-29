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

  /// Checks if the left mouse button is currently pressed.
  Future<bool> isMouseButtonPressed();

  /// Simulates a key press (down and up) with optional modifiers.
  Future<void> performKeyPress(int keyCode, {List<String>? modifiers});

  /// Switches to the next application (Cmd+Tab or Alt+Tab).
  Future<void> switchApplication();

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

  @override
  Future<bool> isMouseButtonPressed() async {
    try {
      final bool? isPressed = await _channel.invokeMethod(
        'isMouseButtonPressed',
      );
      return isPressed ?? false;
    } on PlatformException catch (e) {
      debugPrint("Failed to check mouse button: ${e.message}");
      return false;
    }
  }

  @override
  Future<void> performKeyPress(int keyCode, {List<String>? modifiers}) async {
    try {
      await _channel.invokeMethod('performKeyPress', {
        'keyCode': keyCode,
        'modifiers': modifiers ?? [],
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to perform key press: ${e.message}");
    }
  }

  @override
  Future<void> switchApplication() async {
    try {
      await _channel.invokeMethod('switchApplication');
    } on PlatformException catch (e) {
      debugPrint("Failed to switch application: ${e.message}");
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

  @override
  Future<bool> isMouseButtonPressed() async {
    // Check if left mouse button is pressed using GetAsyncKeyState
    final state = GetAsyncKeyState(VK_LBUTTON);
    return (state & 0x8000) != 0;
  }

  @override
  Future<void> performKeyPress(int keyCode, {List<String>? modifiers}) async {
    final mods = modifiers ?? [];
    final inputs = <INPUT>[];

    // Modifiers down
    if (mods.contains('control')) {
      inputs.add(_createKeyInput(VK_CONTROL, false));
    }
    if (mods.contains('shift')) {
      inputs.add(_createKeyInput(VK_SHIFT, false));
    }
    if (mods.contains('alt')) {
      inputs.add(_createKeyInput(VK_MENU, false));
    }
    if (mods.contains('command')) {
      inputs.add(_createKeyInput(VK_LWIN, false));
    }

    // Key down and up
    inputs.add(_createKeyInput(keyCode, false));
    inputs.add(_createKeyInput(keyCode, true));

    // Modifiers up (reverse order)
    if (mods.contains('command')) {
      inputs.add(_createKeyInput(VK_LWIN, true));
    }
    if (mods.contains('alt')) {
      inputs.add(_createKeyInput(VK_MENU, true));
    }
    if (mods.contains('shift')) {
      inputs.add(_createKeyInput(VK_SHIFT, true));
    }
    if (mods.contains('control')) {
      inputs.add(_createKeyInput(VK_CONTROL, true));
    }

    final pInputs = calloc<INPUT>(inputs.length);
    for (var i = 0; i < inputs.length; i++) {
      pInputs[i] = inputs[i];
    }
    SendInput(inputs.length, pInputs, ffi.sizeOf<INPUT>());
    free(pInputs);
  }

  INPUT _createKeyInput(int keyCode, bool isUp) {
    final input = calloc<INPUT>().ref;
    input.type = INPUT_KEYBOARD;
    input.ki.wVk = keyCode;
    if (isUp) input.ki.dwFlags = KEYEVENTF_KEYUP;
    return input;
  }

  @override
  Future<void> switchApplication() async {
    // Windows Alt + Tab
    final inputs = calloc<INPUT>(4);

    // Alt Down
    inputs[0].type = INPUT_KEYBOARD;
    inputs[0].ki.wVk = VK_MENU; // ALT

    // Tab Down
    inputs[1].type = INPUT_KEYBOARD;
    inputs[1].ki.wVk = VK_TAB;

    // Tab Up
    inputs[2].type = INPUT_KEYBOARD;
    inputs[2].ki.wVk = VK_TAB;
    inputs[2].ki.dwFlags = KEYEVENTF_KEYUP;

    // Alt Up
    inputs[3].type = INPUT_KEYBOARD;
    inputs[3].ki.wVk = VK_MENU;
    inputs[3].ki.dwFlags = KEYEVENTF_KEYUP;

    SendInput(4, inputs, ffi.sizeOf<INPUT>());
    free(inputs);
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

  @override
  Future<bool> isMouseButtonPressed() async {
    return false;
  }

  @override
  Future<void> performKeyPress(int keyCode, {List<String>? modifiers}) async {
    debugPrint("Keyboard press not implemented for this platform yet.");
  }

  @override
  Future<void> switchApplication() async {
    debugPrint("Application switching not implemented for this platform yet.");
  }
}
