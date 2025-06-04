import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stoic_quotes_app/models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  DatabaseService._internal();

  factory DatabaseService() => _instance;

  // Коллекция для цитат
  final CollectionReference firebaseQuotesCollection =
      FirebaseFirestore.instance.collection('quotes');

  // Коллекция для записей дневника
  final CollectionReference firebaseDiaryCollection =
      FirebaseFirestore.instance.collection('diary_notes');

  // ==================== Работа с цитатами ====================

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
          .where('isFavorite', isEqualTo: true)
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

  // ==================== Работа с записями дневника ====================

  // Добавление записи в дневник
Future<Diary> insertDiaryEntry(Diary diaryEntry) async {
  try {
    DocumentReference docRef = firebaseDiaryCollection.doc();

    await docRef.set({
      'text': diaryEntry.text,
      'tags': diaryEntry.tags,
      'timestamp': Timestamp.fromDate(diaryEntry.timestamp),
    });

    final savedEntry = diaryEntry.copyWith(); // копия с теми же полями
    return Diary(
      id: docRef.id,
      text: savedEntry.text,
      tags: savedEntry.tags,
      timestamp: savedEntry.timestamp,
    );
  } catch (e) {
    print('Ошибка при добавлении записи в дневник: $e');
    rethrow;
  }
}

// Обновление записи в дневник
  Future<void> updateDiaryEntry(Diary diaryEntry) async {
  try {
    // Используем `doc(diaryEntry.id)` для обновления записи по её ID
    await firebaseDiaryCollection.doc(diaryEntry.id).update({
      'text': diaryEntry.text,
      'tags': diaryEntry.tags,
      'timestamp': Timestamp.fromDate(diaryEntry.timestamp),
    });
  } catch (e) {
    print('Ошибка при обновлении записи в дневнике: $e');
  }
}
  // Удаление записи из дневника по её documentId
  Future<void> deleteDiaryEntry(String diaryEntryId) async {
    try {
      await firebaseDiaryCollection.doc(diaryEntryId).delete();
    } catch (e) {
      print('Ошибка при удалении записи из дневника: $e');
    }
  }
}