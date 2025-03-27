import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stoic_quotes_app/services/services.dart';
import 'package:stoic_quotes_app/router/router.dart';
import 'firebase_options.dart'; // Файл с настройками Firebase

// Глобальные переменные
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Инициализация Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔔 Инициализация локальных уведомлений
  await NotificationService().init();
  await _scheduleNotificationFromSettings();

  runApp(const MainApp());
}

// Загружает сохраненное время уведомлений и запускает уведомление
Future<void> _scheduleNotificationFromSettings() async {
  final prefs = await SharedPreferences.getInstance();
  final int hour = prefs.getInt("notification_hour") ?? 21;
  final int minute = prefs.getInt("notification_minute") ?? 0;
  final bool isEnabled = prefs.getBool("notifications_enabled") ?? true;

  if (isEnabled) {
    await NotificationService().scheduleDailyNotification(hour, minute);
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return isIOS
        ? CupertinoApp(
            navigatorObservers: [routeObserver],
            navigatorKey: navigatorKey,
            title: 'Stoic Quotes App',
            theme: const CupertinoThemeData(
              primaryColor: CupertinoColors.activeBlue,
            ),
            routes: routes,
            initialRoute: '/',
          )
        : MaterialApp(
            navigatorObservers: [routeObserver],
            navigatorKey: navigatorKey,
            title: 'Stoic Quotes App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            routes: routes,
            initialRoute: '/',
          );
  }
}