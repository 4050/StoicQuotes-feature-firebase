import 'package:flutter/cupertino.dart';
import 'package:stoic_quotes_app/models/models.dart';
import 'package:stoic_quotes_app/repositories/repositories.dart';
import 'package:stoic_quotes_app/services/services.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  _QuoteScreenState createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  final QuoteRepository _quoteRepository = QuoteRepository();
  final DatabaseService _databaseService = DatabaseService();
  String quoteText = "Загрузка цитаты...";
  String authorText = "";
  int? quoteId;

  @override
  void initState() {
    super.initState();
    loadRandomQuote();
  }

  void saveQuote() async {
 if (quoteText.isNotEmpty) {
      await _databaseService.insertQuote(
        Quote(text: quoteText, author: authorText),
        isFavorite: true, // Добавляем isFavorite
      );
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Сохранено"),
          content: const Text("Цитата добавлена в избранное!"),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

    Future<void> loadRandomQuote() async {
  try {
    Quote? quote = await _quoteRepository.fetchRandomQuote();
    if (!mounted) return; // Проверяем, не уничтожен ли виджет

    setState(() {
      quoteText = quote?.text ?? "Нет данных";
      authorText = quote?.author ?? "Неизвестный автор";
    });
  } catch (e) {
    if (!mounted) return; // Еще раз проверяем перед setState()

    setState(() {
      quoteText = "Ошибка загрузки цитаты";
      authorText = "";
    });
  }
}
    @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Stoic Quotes"),
      ),
      child: SafeArea(
         child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Минимальная высота
                    children: [
                      Text(
                        quoteText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontStyle: FontStyle.italic,
                          color: CupertinoColors.black,
                        ),
                      ),
                      Text(
                        authorText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      borderRadius: BorderRadius.circular(30),
                      onPressed: loadRandomQuote,
                      child: const Text("New Quote"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: CupertinoButton(
                        color: CupertinoColors.systemGrey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        borderRadius: BorderRadius.circular(30),
                        onPressed: saveQuote,
                        child: const Text("Save Quote",
                        style: TextStyle(
                          color: CupertinoColors.white,
                          ),
                        ),
                      ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}