import 'package:cloud_firestore/cloud_firestore.dart';

class Diary {
  final String id; // ID документа в Firestore
  final String text;
  final DateTime timestamp;
  final List<String> tags;

  Diary({
    required this.id,
    required this.text,
    required this.timestamp,
    this.tags = const [],
  });

  // Метод для создания объекта из JSON
  factory Diary.fromJson(String id, Map<String, dynamic> json) {
    return Diary(
      id: id, // ID документа
      text: json['text'] ?? 'Нет данных',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  // Метод для преобразования объекта в JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'tags': tags,
    };
  }

  // Метод для создания копии объекта с измененными полями
  Diary copyWith({
    String? text,
    DateTime? timestamp,
    List<String>? tags,
  }) {
    return Diary(
      id: id, // ID остается неизменным
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      tags: tags ?? this.tags,
    );
  }
}