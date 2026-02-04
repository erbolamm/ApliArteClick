import 'package:flutter_test/flutter_test.dart';
import 'package:apliarte_click/main.dart';
import 'package:apliarte_click/models/click_point.dart';

void main() {
  group('Multi-Clip Tests | ClickPoint Model', () {
    test('ClickPoint initialization defaults', () {
      final point = ClickPoint();
      expect(point.name, 'Punto');
      expect(point.delayAfterMs, 1000);
      expect(point.type, ActionType.mouseClick);
      expect(point.modifiers, isEmpty);
      expect(point.id, isNotNull);
    });

    test('ClickPoint copyWith', () {
      final point = ClickPoint(name: 'Test', delayAfterMs: 500);
      final updated = point.copyWith(name: 'Updated', delayAfterMs: 2000);

      expect(updated.id, point.id); // ID should remain same
      expect(updated.name, 'Updated');
      expect(updated.delayAfterMs, 2000);
      expect(updated.type, ActionType.mouseClick); // unchanged
    });
  });

  group('Multi-Clip Tests | State Management', () {
    test('ClickSettings initializes with empty points', () {
      final settings = ClickSettings();
      expect(settings.points, isEmpty);
    });

    test('Add and remove points logic', () {
      var settings = ClickSettings();

      final point1 = ClickPoint(name: "P1", x: 100, y: 100);
      final point2 = ClickPoint(name: "P2", x: 200, y: 200);

      // Simulate logic typically found in notifier
      settings = settings.copyWith(points: [...settings.points, point1]);
      expect(settings.points.length, 1);

      settings = settings.copyWith(points: [...settings.points, point2]);
      expect(settings.points.length, 2);

      // Remove point1
      settings = settings.copyWith(
        points: settings.points.where((p) => p.id != point1.id).toList(),
      );

      expect(settings.points.length, 1);
      expect(settings.points.first.name, "P2");
    });
  });
}
