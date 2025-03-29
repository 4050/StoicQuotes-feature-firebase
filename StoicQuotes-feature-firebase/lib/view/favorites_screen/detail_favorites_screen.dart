import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:stoic_quotes_app/models/models.dart';
import 'package:stoic_quotes_app/services/services.dart';

class QuoteDetailScreen extends StatefulWidget {
  final Quote quote;

  const QuoteDetailScreen({super.key, required this.quote});

  @override
  State<QuoteDetailScreen> createState() => _QuoteDetailScreenState();
}

class _QuoteDetailScreenState extends State<QuoteDetailScreen> with SingleTickerProviderStateMixin {
  final TranslateService _translateService = TranslateService();
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
    // Запускаем анимацию появления текста при открытии экрана
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _translateQuote() async {
    if (_isTranslating) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      if (!_isTranslated) {
        // Переводим на русский
        final translatedText = await _translateService.translate(widget.quote.text);
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
      
      setState(() {
        _isTranslating = false;
      });
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Цитата"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
           /* CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _translateQuote,
              child: _isTranslating
                  ? const CupertinoActivityIndicator()
                  : Icon(
                      _isTranslated ? CupertinoIcons.arrow_counterclockwise : CupertinoIcons.globe,
                      size: 28,
                    ),
            ),*/
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: "${widget.quote.text} - ${widget.quote.author}"));
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text("Скопировано"),
                    content: const Text("Цитата скопирована в буфер обмена!"),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text("OK"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
              child: const Icon(CupertinoIcons.doc_on_doc, size: 28),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Text(
                      _isTranslated ? (_translatedText ?? widget.quote.text) : widget.quote.text,
                      style: TextStyle(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        color: _isTranslated 
                            ? CupertinoColors.systemGrey 
                            : CupertinoColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                "- ${widget.quote.author}",
                style: const TextStyle(
                  fontSize: 18,
                  color: CupertinoColors.inactiveGray,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                width: screenWidth * 0.8,
                height: 30,
              ),
              SizedBox(
                width: screenWidth * 0.8,
                child: CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  borderRadius: BorderRadius.circular(30),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Закрыть"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
