import 'package:cloud_firestore/cloud_firestore.dart';

class Diary {
  final String text;
  final DateTime timestamp;
  final List<String> tags;

  Diary({
    required this.text,
    required this.timestamp,
    this.tags = const [],
  });

  // Метод для создания объекта из JSON
  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
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
}