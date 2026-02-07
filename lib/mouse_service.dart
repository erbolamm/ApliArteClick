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
  Future<void> performClick({
    double? x,
    double? y,
    String button = 'left',
    int clickCount = 1,
  });

  /// Checks if the application has the necessary permissions to control the mouse.
  Future<bool> checkPermissions();

  /// Retrieves the current global mouse cursor position.
  Future<Map<String, double>?> getMousePosition();

  /// Checks if the left mouse button is currently pressed.
  @Deprecated('Use getPressedButtons instead')
  Future<bool> isMouseButtonPressed();

  /// Returns a bitmask of pressed mouse buttons.
  Future<int> getPressedButtons();

  /// Simulates a key down event.
  Future<void> performKeyDown(int keyCode);

  /// Simulates a key up event.
  Future<void> performKeyUp(int keyCode);

  /// Simulates a key press (down and up) with optional modifiers.
  Future<void> performKeyPress(int keyCode, {List<String>? modifiers});

  /// Switches to the next application (Cmd+Tab or Alt+Tab).
  Future<void> switchApplication();

  /// Shows a preview icon at the specified global coordinates.
  Future<void> showPreview(double x, double y);

  /// Hides the preview icon.
  Future<void> hidePreview();

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
  Future<void> performKeyDown(int keyCode) async {
    try {
      await _channel.invokeMethod('performKeyDown', {'keyCode': keyCode});
    } on PlatformException catch (e) {
      debugPrint("Failed to perform key down: ${e.message}");
    }
  }

  @override
  Future<void> performKeyUp(int keyCode) async {
    try {
      await _channel.invokeMethod('performKeyUp', {'keyCode': keyCode});
    } on PlatformException catch (e) {
      debugPrint("Failed to perform key up: ${e.message}");
    }
  }

  // ... existing methods ...
  @override
  Future<void> performClick({
    double? x,
    double? y,
    String button = 'left',
    int clickCount = 1,
  }) async {
    try {
      await _channel.invokeMethod('performClick', {
        'x': x,
        'y': y,
        'button': button,
        'clickCount': clickCount,
      });
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
  @override
  Future<bool> isMouseButtonPressed() async {
    try {
      // Fallback for older interface, strictly checks left button
      final buttons = await getPressedButtons();
      return (buttons & 1) != 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getPressedButtons() async {
    try {
      final int? mask = await _channel.invokeMethod('getPressedMouseButtons');
      return mask ?? 0;
    } on PlatformException catch (e) {
      debugPrint("Failed to get pressed buttons: ${e.message}");
      return 0;
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

  @override
  Future<void> showPreview(double x, double y) async {
    try {
      await _channel.invokeMethod('showPreview', {'x': x, 'y': y});
    } on PlatformException catch (e) {
      debugPrint("Failed to show preview: ${e.message}");
    }
  }

  @override
  Future<void> hidePreview() async {
    try {
      await _channel.invokeMethod('hidePreview');
    } on PlatformException catch (e) {
      debugPrint("Failed to hide preview: ${e.message}");
    }
  }
}

/// Windows implementation using Win32 API directly via FFI.
class _WindowsMouseService implements MouseService {
  @override
  Future<void> performKeyDown(int keyCode) async {
    final input = _createKeyInput(keyCode, false);
    final pInput = calloc<INPUT>();
    pInput.ref = input;
    SendInput(1, pInput, ffi.sizeOf<INPUT>());
    free(pInput);
  }

  @override
  Future<void> performKeyUp(int keyCode) async {
    final input = _createKeyInput(keyCode, true);
    final pInput = calloc<INPUT>();
    pInput.ref = input;
    SendInput(1, pInput, ffi.sizeOf<INPUT>());
    free(pInput);
  }

  @override
  Future<void> performClick({
    double? x,
    double? y,
    String button = 'left',
    int clickCount = 1,
  }) async {
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
    final state = GetAsyncKeyState(VK_LBUTTON);
    return (state & 0x8000) != 0;
  }

  @override
  Future<int> getPressedButtons() async {
    int mask = 0;
    if ((GetAsyncKeyState(VK_LBUTTON) & 0x8000) != 0) mask |= 1;
    if ((GetAsyncKeyState(VK_RBUTTON) & 0x8000) != 0) mask |= 2;
    // MBUTTON is 4
    return mask;
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
    var actualKey = keyCode;

    // Windows uses 0 for key input wrapper, we use INPUT structure directly in createKeyInput?
    // Oh wait, _createKeyInput creates an INPUT struct.

    final input = calloc<INPUT>().ref;
    input.type = INPUT_KEYBOARD;
    input.ki.wVk = actualKey;
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

  @override
  Future<void> showPreview(double x, double y) async {
    // Windows preview not implemented yet
  }

  @override
  Future<void> hidePreview() async {
    // Windows preview not implemented yet
  }
}

class _GenericMouseService implements MouseService {
  @override
  Future<void> performKeyDown(int keyCode) async {
    debugPrint("Key down not implemented for this platform yet.");
  }

  @override
  Future<void> performKeyUp(int keyCode) async {
    debugPrint("Key up not implemented for this platform yet.");
  }

  @override
  Future<void> performClick({
    double? x,
    double? y,
    String button = 'left',
    int clickCount = 1,
  }) async {
    debugPrint("Mouse clicking not implemented for this platform yet.");
  }

  @override
  Future<bool> checkPermissions() async {
    return true;
  }

  // ... rest of generic implementation
  @override
  Future<Map<String, double>?> getMousePosition() async {
    return null;
  }

  @override
  Future<bool> isMouseButtonPressed() async {
    return false;
  }

  @override
  Future<int> getPressedButtons() async {
    return 0;
  }

  @override
  Future<void> performKeyPress(int keyCode, {List<String>? modifiers}) async {
    debugPrint("Keyboard press not implemented for this platform yet.");
  }

  @override
  Future<void> switchApplication() async {
    debugPrint("Application switching not implemented for this platform yet.");
  }

  @override
  Future<void> showPreview(double x, double y) async {}

  @override
  Future<void> hidePreview() async {}
}
