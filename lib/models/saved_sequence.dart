import 'package:uuid/uuid.dart';
import 'click_point.dart';

class SavedSequence {
  final String id;
  final String name;
  final List<ClickPoint> points;

  SavedSequence({String? id, required this.name, required this.points})
    : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points.map((p) => p.toJson()).toList(),
    };
  }

  factory SavedSequence.fromJson(Map<String, dynamic> json) {
    return SavedSequence(
      id: json['id'] as String?,
      name: json['name'] as String,
      points: (json['points'] as List<dynamic>)
          .map((e) => ClickPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() =>
      'SavedSequence(id: $id, name: $name, points: ${points.length})';
}
