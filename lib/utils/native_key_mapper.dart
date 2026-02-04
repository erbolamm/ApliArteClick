import 'package:flutter/services.dart';

class NativeKeyMapper {
  /// Returns the native key code for the given [key].
  ///
  /// [isMacOS] and [isWindows] arguments allow for easy testing without
  /// relying on `Platform` static checks.
  static int? getNativeKeyCode(
    LogicalKeyboardKey key, {
    bool isMacOS = false,
    bool isWindows = false,
  }) {
    if (isMacOS) {
      return _getMacKeyCode(key);
    } else if (isWindows) {
      return _getWindowsKeyCode(key);
    }
    return null;
  }

  static int? _getMacKeyCode(LogicalKeyboardKey key) {
    // --- Standard Controls ---
    if (key == LogicalKeyboardKey.enter) return 36;
    if (key == LogicalKeyboardKey.tab) return 48;
    if (key == LogicalKeyboardKey.space) return 49;
    if (key == LogicalKeyboardKey.escape) return 53;
    if (key == LogicalKeyboardKey.backspace) return 51;
    if (key == LogicalKeyboardKey.delete) return 117;

    // --- Arrow Keys ---
    if (key == LogicalKeyboardKey.arrowLeft) return 123;
    if (key == LogicalKeyboardKey.arrowRight) return 124;
    if (key == LogicalKeyboardKey.arrowDown) return 125;
    if (key == LogicalKeyboardKey.arrowUp) return 126;

    // --- Letters (QWERTY Standard) ---
    if (key == LogicalKeyboardKey.keyA) return 0;
    if (key == LogicalKeyboardKey.keyS) return 1;
    if (key == LogicalKeyboardKey.keyD) return 2;
    if (key == LogicalKeyboardKey.keyF) return 3;
    if (key == LogicalKeyboardKey.keyH) return 4;
    if (key == LogicalKeyboardKey.keyG) return 5;
    if (key == LogicalKeyboardKey.keyZ) return 6;
    if (key == LogicalKeyboardKey.keyX) return 7;
    if (key == LogicalKeyboardKey.keyC) return 8;
    if (key == LogicalKeyboardKey.keyV) return 9;
    // 10 is hidden/iso key
    if (key == LogicalKeyboardKey.keyB) return 11;
    if (key == LogicalKeyboardKey.keyQ) return 12;
    if (key == LogicalKeyboardKey.keyW) return 13;
    if (key == LogicalKeyboardKey.keyE) return 14;
    if (key == LogicalKeyboardKey.keyR) return 15;
    if (key == LogicalKeyboardKey.keyY) return 16;
    if (key == LogicalKeyboardKey.keyT) return 17;
    if (key == LogicalKeyboardKey.digit1) return 18;
    if (key == LogicalKeyboardKey.digit2) return 19;
    if (key == LogicalKeyboardKey.digit3) return 20;
    if (key == LogicalKeyboardKey.digit4) return 21;
    if (key == LogicalKeyboardKey.digit6) return 22;
    if (key == LogicalKeyboardKey.digit5) return 23;
    if (key == LogicalKeyboardKey.equal) return 24;
    if (key == LogicalKeyboardKey.digit9) return 25;
    if (key == LogicalKeyboardKey.digit7) return 26;
    if (key == LogicalKeyboardKey.minus) return 27;
    if (key == LogicalKeyboardKey.digit8) return 28;
    if (key == LogicalKeyboardKey.digit0) return 29;
    if (key == LogicalKeyboardKey.bracketRight) return 30;
    if (key == LogicalKeyboardKey.keyO) return 31;
    if (key == LogicalKeyboardKey.keyU) return 32;
    if (key == LogicalKeyboardKey.bracketLeft) return 33;
    if (key == LogicalKeyboardKey.keyI) return 34;
    if (key == LogicalKeyboardKey.keyP) return 35;
    if (key == LogicalKeyboardKey.keyL) return 37;
    if (key == LogicalKeyboardKey.keyJ) return 38;
    if (key == LogicalKeyboardKey.quote) return 39;
    if (key == LogicalKeyboardKey.keyK) return 40;
    if (key == LogicalKeyboardKey.semicolon) return 41;
    if (key == LogicalKeyboardKey.backslash) return 42;
    if (key == LogicalKeyboardKey.comma) return 43;
    if (key == LogicalKeyboardKey.slash) return 44;
    if (key == LogicalKeyboardKey.numpadAdd) return 45;
    if (key == LogicalKeyboardKey.keyM) return 46;
    if (key == LogicalKeyboardKey.period) return 47;

    // --- Function Keys ---
    if (key.keyId >= LogicalKeyboardKey.f1.keyId &&
        key.keyId <= LogicalKeyboardKey.f12.keyId) {
      final fIdx = key.keyId - LogicalKeyboardKey.f1.keyId;
      // F1=122, F2=120, F3=99, F4=118, F5=96, F6=97,
      // F7=98, F8=100, F9=101, F10=109, F11=103, F12=111
      const fCodes = [122, 120, 99, 118, 96, 97, 98, 100, 101, 109, 103, 111];
      if (fIdx >= 0 && fIdx < fCodes.length) return fCodes[fIdx];
    }

    return null;
  }

  static int? _getWindowsKeyCode(LogicalKeyboardKey key) {
    // --- standard controls ---
    if (key == LogicalKeyboardKey.enter) return 0x0D;
    if (key == LogicalKeyboardKey.tab) return 0x09;
    if (key == LogicalKeyboardKey.space) return 0x20;
    if (key == LogicalKeyboardKey.escape) return 0x1B;
    if (key == LogicalKeyboardKey.backspace) return 0x08;
    if (key == LogicalKeyboardKey.delete) return 0x2E;

    // --- Arrow Keys ---
    if (key == LogicalKeyboardKey.arrowLeft) return 0x25;
    if (key == LogicalKeyboardKey.arrowUp) return 0x26;
    if (key == LogicalKeyboardKey.arrowRight) return 0x27;
    if (key == LogicalKeyboardKey.arrowDown) return 0x28;

    // --- Letters A-Z ---
    if (key.keyId >= LogicalKeyboardKey.keyA.keyId &&
        key.keyId <= LogicalKeyboardKey.keyZ.keyId) {
      // Logic: A is 0x41 in Windows VK
      return 0x41 + (key.keyId - LogicalKeyboardKey.keyA.keyId);
    }

    // --- Numbers 0-9 ---
    if (key.keyId >= LogicalKeyboardKey.digit0.keyId &&
        key.keyId <= LogicalKeyboardKey.digit9.keyId) {
      // Logic: 0 is 0x30
      return 0x30 + (key.keyId - LogicalKeyboardKey.digit0.keyId);
    }

    // --- Function Keys ---
    if (key.keyId >= LogicalKeyboardKey.f1.keyId &&
        key.keyId <= LogicalKeyboardKey.f12.keyId) {
      return 0x70 + (key.keyId - LogicalKeyboardKey.f1.keyId);
    }

    return null;
  }
}
