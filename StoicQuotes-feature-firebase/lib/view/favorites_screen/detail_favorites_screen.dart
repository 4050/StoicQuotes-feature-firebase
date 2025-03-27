import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:stoic_quotes_app/models/models.dart';

class QuoteDetailScreen extends StatelessWidget {
  final Quote quote;

  const QuoteDetailScreen({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Цитата"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: "${quote.text} - ${quote.author}"));
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
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                quote.text,
                style: const TextStyle(
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "- ${quote.author}",
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
