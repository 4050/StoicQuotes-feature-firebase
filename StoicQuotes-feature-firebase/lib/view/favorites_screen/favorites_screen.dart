import 'package:flutter/cupertino.dart';
import 'package:stoic_quotes_app/services/services.dart';
import 'package:stoic_quotes_app/models/models.dart';
import 'package:stoic_quotes_app/main.dart';
import 'package:stoic_quotes_app/view/view.dart';


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
    final confirmed = await showCupertinoDialog<bool>(
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Избранное"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: loadFavorites,
          child: const Icon(CupertinoIcons.refresh, size: 28),
        ),
      ),
      child: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    if (favoriteQuotes.isEmpty) {
      return const Center(
        child: Text(
          "Список избранных цитат пуст",
          style: TextStyle(
            fontSize: 18,
            color: CupertinoColors.inactiveGray,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return CupertinoScrollbar(
      child: ListView.builder(
        itemCount: favoriteQuotes.length,
        itemBuilder: (context, index) {
          final quote = favoriteQuotes[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => QuoteDetailScreen(quote: quote),
                ),
              );
            },
          child: CupertinoListTile(
            title: Text(
              quote.text,
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
            subtitle: Text(
              "- ${quote.author}",
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.inactiveGray,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => confirmDelete(quote),
              child: const Icon(
                CupertinoIcons.trash,
                color: CupertinoColors.destructiveRed,
              ),
            ),
           ),
          );
        },
      ),
    );
  }
}