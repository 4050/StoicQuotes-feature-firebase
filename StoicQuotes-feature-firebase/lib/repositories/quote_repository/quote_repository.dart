import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stoic_quotes_app/models/models.dart';

class QuoteRepository {
  final String _apiUrl = "https://api.allorigins.win/raw?url=https://zenquotes.io/api/random";

  Future<Quote?> fetchRandomQuote() async {
    final response = await http.get(Uri.parse(_apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return Quote.fromJson(data[0]);
    } else {
      throw Exception('Ошибка загрузки цитаты');
    }
  }
}
