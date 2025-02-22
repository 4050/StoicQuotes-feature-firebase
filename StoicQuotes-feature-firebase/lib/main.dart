import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stoic_quotes_app/view/view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ensure this file exists

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Ensure Firebase is initialized correctly for Web
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ✅ Required for Web
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return CupertinoApp(
        navigatorObservers: [routeObserver],
        title: 'Stoic Quotes App',
        theme: const CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
        ),
        home: const HomeScreen(),
      );
    } else {
      return MaterialApp(
        navigatorObservers: [routeObserver],
        title: 'Stoic Quotes App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen(),
      );
    }
  }
}
