import 'package:flutter/cupertino.dart';
import 'package:stoic_quotes_app/view/view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: _selectedIndex == 3
            ? CupertinoColors.systemGroupedBackground
            : CupertinoColors.systemBackground,
        activeColor: CupertinoColors.activeBlue,
        inactiveColor: CupertinoColors.inactiveGray,
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        border: Border( // Убираем разделительную линию
          top: BorderSide.none,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            label: "Цитаты",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.star),
            label: "Избранное",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.pen),
            label: "Дневник",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: "Настройки",
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return const QuoteScreen();
              case 1:
                return const FavoritesScreen();
              case 2:
                return const DiaryScreen();
              case 3:
                return const SettingsScreen();
              default:
                return const QuoteScreen();
            }
          },
        );
      },
    );
  }
}
