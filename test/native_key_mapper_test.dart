import 'package:apliarte_click/utils/native_key_mapper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NativeKeyMapper Tests', () {
    test('Mac Key Codes', () {
      // Basic Controls
      expect(
        NativeKeyMapper.getNativeKeyCode(LogicalKeyboardKey.tab, isMacOS: true),
        48,
      );
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.space,
          isMacOS: true,
        ),
        49,
      );

      // Arrows
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.arrowLeft,
          isMacOS: true,
        ),
        123,
      );

      // Letters
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.keyA,
          isMacOS: true,
        ),
        0,
      );
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.keyZ,
          isMacOS: true,
        ),
        6,
      );
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.keyM,
          isMacOS: true,
        ),
        46,
      );

      // Numbers
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.digit0,
          isMacOS: true,
        ),
        29,
      );
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.digit1,
          isMacOS: true,
        ),
        18,
      );

      // F-Keys
      expect(
        NativeKeyMapper.getNativeKeyCode(LogicalKeyboardKey.f1, isMacOS: true),
        122,
      );
      expect(
        NativeKeyMapper.getNativeKeyCode(LogicalKeyboardKey.f12, isMacOS: true),
        111,
      );
    });

    test('Windows Key Codes', () {
      // Basic Controls
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.tab,
          isWindows: true,
        ),
        0x09,
      );
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.space,
          isWindows: true,
        ),
        0x20,
      );

      // Arrows
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.arrowUp,
          isWindows: true,
        ),
        0x26,
      );

      // Letters (A=0x41)
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.keyA,
          isWindows: true,
        ),
        0x41,
      );
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.keyZ,
          isWindows: true,
        ),
        0x5A,
      );

      // Numbers (0=0x30)
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.digit0,
          isWindows: true,
        ),
        0x30,
      );
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.digit9,
          isWindows: true,
        ),
        0x39,
      );

      // F-Keys (F1=0x70)
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.f1,
          isWindows: true,
        ),
        0x70,
      );
    });
  });
}
