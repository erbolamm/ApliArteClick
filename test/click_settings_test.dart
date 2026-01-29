import 'package:flutter_test/flutter_test.dart';
import 'package:apliarte_click/main.dart';

void main() {
  group('ApliArte Click Pro Tests', () {
    test('ClickSettings initial state is correct', () {
      final settings = ClickSettings();

      expect(settings.isRunning, false);
      expect(settings.showWelcome, true);
      expect(settings.isPickingPosition, false);
      expect(settings.actionType, ActionType.mouseClick);
      expect(settings.hours, 0);
      expect(settings.minutes, 0);
      expect(settings.seconds, 10);
      expect(settings.milliseconds, 0);
      expect(settings.clickCount, 0);
    });

    test('ClickSettings copyWith works correctly', () {
      final settings = ClickSettings();
      final updated = settings.copyWith(
        isRunning: true,
        clickCount: 5,
        hours: 1,
      );

      expect(updated.isRunning, true);
      expect(updated.clickCount, 5);
      expect(updated.hours, 1);
      expect(updated.seconds, 10); // unchanged
    });

    test('ClickSettings totalIntervalMs calculation', () {
      final settings = ClickSettings(
        hours: 1,
        minutes: 30,
        seconds: 45,
        milliseconds: 500,
      );

      final expected = (1 * 3600000) + (30 * 60000) + (45 * 1000) + 500;
      expect(settings.totalIntervalMs, expected);
    });

    test('ActionType enum has correct values', () {
      expect(ActionType.values.length, 2);
      expect(ActionType.values.contains(ActionType.mouseClick), true);
      expect(ActionType.values.contains(ActionType.keyboard), true);
    });
  });
}
