import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../main.dart'; // For ActionType

enum KeyEventType {
  press, // Down and Up (Click)
  down, // Hold
  up, // Release
}

class ClickPoint {
  final String id;
  final String name;
  final ActionType type;
  final double? x;
  final double? y;
  final int delayAfterMs;
  final LogicalKeyboardKey? key;
  final List<String> modifiers;
  final KeyEventType keyEventType;
  final String mouseButton;
  final int clickCount;
  final String? text;

  // Advanced Flow
  final List<ClickPoint> nestedPoints;
  final int loopCount;

  ClickPoint({
    String? id,
    this.name = 'Punto',
    this.type = ActionType.mouseClick,
    this.x,
    this.y,
    this.delayAfterMs = 1000,
    this.key,
    this.modifiers = const [],
    this.keyEventType = KeyEventType.press,
    this.mouseButton = 'left',
    this.clickCount = 1,
    this.text,
    this.nestedPoints = const [],
    this.loopCount = 1,
  }) : id = id ?? const Uuid().v4();

  ClickPoint copyWith({
    String? name,
    ActionType? type,
    double? x,
    double? y,
    int? delayAfterMs,
    LogicalKeyboardKey? key,
    List<String>? modifiers,
    KeyEventType? keyEventType,
    String? mouseButton,
    int? clickCount,
    String? text,
    List<ClickPoint>? nestedPoints,
    int? loopCount,
  }) {
    return ClickPoint(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      delayAfterMs: delayAfterMs ?? this.delayAfterMs,
      key: key ?? this.key,
      modifiers: modifiers ?? this.modifiers,
      keyEventType: keyEventType ?? this.keyEventType,
      mouseButton: mouseButton ?? this.mouseButton,
      clickCount: clickCount ?? this.clickCount,
      text: text ?? this.text,
      nestedPoints: nestedPoints ?? this.nestedPoints,
      loopCount: loopCount ?? this.loopCount,
    );
  }

  @override
  String toString() {
    return 'ClickPoint(name: $name, type: $type, x: $x, y: $y, delay: $delayAfterMs, loop: $loopCount)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'x': x,
      'y': y,
      'delayAfterMs': delayAfterMs,
      'keyId': key?.keyId,
      'modifiers': modifiers,
      'keyEventType': keyEventType.index,
      'mouseButton': mouseButton,
      'clickCount': clickCount,
      'text': text,
      'nestedPoints': nestedPoints.map((p) => p.toJson()).toList(),
      'loopCount': loopCount,
    };
  }

  factory ClickPoint.fromJson(Map<String, dynamic> json) {
    return ClickPoint(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Punto',
      type: ActionType.values[json['type'] as int? ?? 0],
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
      delayAfterMs: (json['delayAfterMs'] as int?) ?? 1000,
      key: json['keyId'] != null
          ? LogicalKeyboardKey.findKeyByKeyId(json['keyId'] as int)
          : null,
      modifiers: (json['modifiers'] as List<dynamic>?)?.cast<String>() ?? [],
      keyEventType: KeyEventType.values[json['keyEventType'] as int? ?? 0],
      mouseButton: json['mouseButton'] as String? ?? 'left',
      clickCount: json['clickCount'] as int? ?? 1,
      text: json['text'] as String?,
      nestedPoints:
          (json['nestedPoints'] as List<dynamic>?)
              ?.map((p) => ClickPoint.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      loopCount: json['loopCount'] as int? ?? 1,
    );
  }
}
