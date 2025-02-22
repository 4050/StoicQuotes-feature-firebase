import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stoic_quotes_app/models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  DatabaseService._internal();

  factory DatabaseService() => _instance;

  final CollectionReference firebaseQuotesCollection =
      FirebaseFirestore.instance.collection('quotes');

  // Добавление или обновление цитаты
  Future<void> insertQuote(Quote quote, {bool isFavorite = false}) async {
    try {
      await firebaseQuotesCollection.doc(quote.text).set({
        'text': quote.text,
        'author': quote.author,
        'isFavorite': isFavorite, // Новое поле
      });
    } catch (e) {
      print('Ошибка при добавлении цитаты: $e');
    }
  }

  // Удаление цитаты по её тексту (используем text как documentId)
  Future<void> deleteQuote(Quote quote) async {
    try {
      await firebaseQuotesCollection.doc(quote.text).delete();
    } catch (e) {
      print('Ошибка при удалении цитаты: $e');
    }
  }

  // Получение всех избранных цитат
  Future<List<Quote>> getFavoriteQuotes() async {
    try {
      QuerySnapshot snapshot = await firebaseQuotesCollection
          .where('isFavorite', isEqualTo: true) // Фильтрация по избранным
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Quote(
          text: data['text'],
          author: data['author'],
        );
      }).toList();
    } catch (e) {
      print('Ошибка при получении избранных цитат: $e');
      return [];
    }
  }

  // Обновление статуса избранной цитаты
  Future<void> updateFavoriteStatus(Quote quote, bool isFavorite) async {
    try {
      await firebaseQuotesCollection.doc(quote.text).update({
        'isFavorite': isFavorite,
      });
    } catch (e) {
      print('Ошибка при обновлении статуса избранного: $e');
    }
  }
}
