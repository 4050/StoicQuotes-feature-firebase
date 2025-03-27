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
      text: json['q'] ?? 'Нет данных',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}