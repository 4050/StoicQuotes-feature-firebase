import 'package:flutter/cupertino.dart';
import 'package:stoic_quotes_app/models/models.dart';
import 'package:stoic_quotes_app/repositories/repositories.dart';
import 'package:stoic_quotes_app/services/services.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  _QuoteScreenState createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> with SingleTickerProviderStateMixin {
  final QuoteRepository _quoteRepository = QuoteRepository();
  final DatabaseService _databaseService = DatabaseService();
  final TranslateService _translateService = TranslateService();
  String quoteText = "Загрузка цитаты...";
  String authorText = "";
  int? quoteId;
  String? _translatedText;
  bool _isTranslating = false;
  bool _isTranslated = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    loadRandomQuote();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _translateQuote() async {
    if (_isTranslating || !mounted) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      if (!_isTranslated) {
        // Переводим на русский
        final translatedText = await _translateService.translate(quoteText);
        if (!mounted) return;
        setState(() {
          _translatedText = translatedText;
          _isTranslated = true;
        });
      } else {
        // Возвращаемся к оригинальному тексту
        setState(() {
          _isTranslated = false;
        });
      }
      
      // Анимация перехода
      _fadeController.reset();
      await _fadeController.forward();
      
      if (!mounted) return;
      setState(() {
        _isTranslating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTranslating = false;
      });
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Ошибка перевода"),
          content: Text(e.toString()),
          actions: [
            CupertinoDialogAction(
              child: const Text("Повторить"),
              onPressed: () {
                Navigator.pop(context);
                _translateQuote();
              },
            ),
            CupertinoDialogAction(
              child: const Text("Отмена"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  void saveQuote() async {
    if (quoteText.isNotEmpty) {
      await _databaseService.insertQuote(
        Quote(text: quoteText, author: authorText),
        isFavorite: true,
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
      if (!mounted) return;

      setState(() {
        quoteText = quote?.text ?? "Нет данных";
        authorText = quote?.author ?? "Неизвестный автор";
        _isTranslated = false;
        _translatedText = null;
      });
      _fadeController.forward();
    } catch (e) {
      if (!mounted) return;

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
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Stoic Quotes"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _translateQuote,
          child: _isTranslating
              ? const CupertinoActivityIndicator()
              : Icon(
                  _isTranslated ? CupertinoIcons.arrow_counterclockwise : CupertinoIcons.globe,
                  size: 28,
                ),
        ),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Text(
                              _isTranslated ? (_translatedText ?? quoteText) : quoteText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontStyle: FontStyle.italic,
                                color: CupertinoColors.black,
                              ),
                            ),
                          );
                        },
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
                      child: const Text(
                        "Save Quote",
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