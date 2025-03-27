import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stoic_quotes_app/main.dart'; // Импортируем navigatorKey

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Kiev'));

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response);
      },
    );

    // Запуск уведомления при старте
    await scheduleDailyNotificationFromSettings();
  }

  // Обработчик нажатия на уведомление
  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null && navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed("/diary");
    } else {
      print("Ошибка: navigatorKey или payload == null");
    }
  }

  // Получение сохраненного времени уведомлений из SharedPreferences
  Future<Map<String, int>> getSavedNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final int hour = prefs.getInt("notification_hour") ?? 21;
    final int minute = prefs.getInt("notification_minute") ?? 0;
    return {"hour": hour, "minute": minute};
  }

  // Сохранение времени уведомлений в SharedPreferences
  Future<void> saveNotificationTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("notification_hour", hour);
    await prefs.setInt("notification_minute", minute);

    // Перезапускаем уведомление с новым временем
    await scheduleDailyNotification(hour, minute);
  }

  // Запуск уведомления с сохраненного времени
  Future<void> scheduleDailyNotificationFromSettings() async {
    final time = await getSavedNotificationTime();
    await scheduleDailyNotification(time["hour"]!, time["minute"]!);
  }

  // Запуск ежедневного уведомления в указанное время
  Future<void> scheduleDailyNotification(int hour, int minute) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_channel_id',
      'Daily Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      "Время для размышлений",
      "Запиши свои мысли перед сном",
      scheduledTime,
      notificationDetails,
      payload: "diary",
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Отключение уведомлений
  Future<void> cancelNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(1);
  }
}