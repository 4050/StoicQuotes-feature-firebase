import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stoic_quotes_app/services/services.dart';
import 'package:stoic_quotes_app/models/models.dart';
import 'package:stoic_quotes_app/main.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with RouteAware {
  final DatabaseService _databaseService = DatabaseService();
  List<Quote> favoriteQuotes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  void loadFavorites() async {
    setState(() {
      isLoading = true;
    });

    final quotes = await _databaseService.getFavoriteQuotes();
    setState(() {
      favoriteQuotes = quotes;
      isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    loadFavorites();
  }

  Future<void> confirmDelete(Quote quote) async {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final confirmed = isIOS
        ? await showCupertinoDialog<bool>(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text("Удалить цитату?"),
              content: const Text("Вы уверены, что хотите удалить эту цитату?"),
              actions: [
                CupertinoDialogAction(
                  child: const Text("Отмена"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: const Text("Удалить"),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          )
        : await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Удалить цитату?"),
              content: const Text("Вы уверены, что хотите удалить эту цитату?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Отмена"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text("Удалить"),
                ),
              ],
            ),
          );

    if (confirmed ?? false) {
      await deleteFavorite(quote);
    }
  }

  Future<void> deleteFavorite(Quote quote) async {
    await _databaseService.deleteQuote(quote);
    setState(() {
      favoriteQuotes.remove(quote);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return isIOS
        ? CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: const Text("Избранное"),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: loadFavorites,
                child: const Icon(CupertinoIcons.refresh, size: 28),
              ),
            ),
            child: buildContent(isIOS),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text("Избранное"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: loadFavorites,
                ),
              ],
            ),
            body: buildContent(isIOS),
          );
  }

  Widget buildContent(bool isIOS) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(), // Используем ProgressIndicator для Android
      );
    }

    if (favoriteQuotes.isEmpty) {
      return const Center(
        child: Text(
          "Список избранных цитат пуст",
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: favoriteQuotes.length,
      itemBuilder: (context, index) {
        final quote = favoriteQuotes[index];
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quote.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "- ${quote.author}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isIOS ? CupertinoIcons.delete : Icons.delete,
                  color: Colors.red,
                  size: 28,
                ),
                onPressed: () async {
                  await confirmDelete(quote);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
