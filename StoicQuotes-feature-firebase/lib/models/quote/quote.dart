class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});

  // Метод для создания объекта из JSON
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['q'] ?? 'Нет данных',
      author: json['a'] ?? 'Неизвестный автор',
    );
  }
}