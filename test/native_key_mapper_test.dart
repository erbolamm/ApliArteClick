import 'package:apliarte_click/utils/native_key_mapper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NativeKeyMapper Tests', () {
    test('getLogicalKeyForChar maps common letters', () {
      expect(
        NativeKeyMapper.getLogicalKeyForChar('a'),
        LogicalKeyboardKey.keyA,
      );
      expect(
        NativeKeyMapper.getLogicalKeyForChar('z'),
        LogicalKeyboardKey.keyZ,
      );
      expect(
        NativeKeyMapper.getLogicalKeyForChar('A'),
        LogicalKeyboardKey.keyA,
      ); // Case insensitive
      expect(
        NativeKeyMapper.getLogicalKeyForChar('G'),
        LogicalKeyboardKey.keyG,
      );
    });

    test('getLogicalKeyForChar maps common digits', () {
      expect(
        NativeKeyMapper.getLogicalKeyForChar('0'),
        LogicalKeyboardKey.digit0,
      );
      expect(
        NativeKeyMapper.getLogicalKeyForChar('9'),
        LogicalKeyboardKey.digit9,
      );
      expect(
        NativeKeyMapper.getLogicalKeyForChar('5'),
        LogicalKeyboardKey.digit5,
      );
    });

    test('getLogicalKeyForChar maps basic special characters', () {
      expect(
        NativeKeyMapper.getLogicalKeyForChar(' '),
        LogicalKeyboardKey.space,
      );
      expect(
        NativeKeyMapper.getLogicalKeyForChar('\n'),
        LogicalKeyboardKey.enter,
      );
    });

    test('getLogicalKeyForChar returns null for empty or unknown', () {
      expect(NativeKeyMapper.getLogicalKeyForChar(''), null);
      // We haven't mapped symbols like '$' or complex chars yet in the simplified version
      // So assuming they return null for now, or if mapped, we'd test them.
      // Based on previous code view, only space and newline were mapped explicitly besides alphanumeric.
    });

    test('getNativeKeyCode returns correct codes for MacOS', () {
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.keyA,
          isMacOS: true,
        ),
        0,
      );
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.keyN,
          isMacOS: true,
        ),
        45,
      ); // This was missing
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.keyM,
          isMacOS: true,
        ),
        46,
      );
      expect(
        NativeKeyMapper.getNativeKeyCode(
          LogicalKeyboardKey.numpadAdd,
          isMacOS: true,
        ),
        69,
      ); // This was 45
    });
  });
}
