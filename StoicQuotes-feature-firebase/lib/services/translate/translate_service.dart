import 'package:translator/translator.dart';

class TranslateService {
  final translator = GoogleTranslator();
  
  Future<String> translate(String text, {String to = 'ru'}) async {
    try {
      final translation = await translator.translate(
        text,
        to: to,
      );
      return translation.text;
    } catch (e) {
      throw Exception('Ошибка перевода: $e');
    }
  }
} 