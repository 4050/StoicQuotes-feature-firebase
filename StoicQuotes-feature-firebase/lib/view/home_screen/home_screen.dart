import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stoic_quotes_app/view/view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Список экранов для удобства переключения на Android
  final List<Widget> _screens = const [
    QuoteScreen(),
    FavoritesScreen(),
    DiaryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS;

    if (isIOS) {
      // iOS-версия
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
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
          ],
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return CupertinoTabView(
                builder: (context) => const QuoteScreen(),
              );
            case 1:
              return CupertinoTabView(
                builder: (context) => const FavoritesScreen(),
              );
            case 2:
              return CupertinoTabView(
                builder: (context) => const DiaryScreen(),
              );
            default:
              return CupertinoTabView(
                builder: (context) => const QuoteScreen(),
              );
          }
        },
      );
    } else {
      // Android-версия
      return Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: "Цитаты",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: "Избранное",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: "Дневник",
            ),
          ],
          onTap: _onItemTapped,
        ),
      );
    }
  }
}