import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stoic_quotes_app/services/services.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  int selectedHour = 21;
  int selectedMinute = 0;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  late Future<void> _loadSettingsFuture;

  @override
  void initState() {
    super.initState();
    _loadSettingsFuture = _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedHour = prefs.getInt('notification_hour') ?? 21;
      selectedMinute = prefs.getInt('notification_minute') ?? 0;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    });
  }

  Future<void> _saveNotificationTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', hour);
    await prefs.setInt('notification_minute', minute);
    setState(() {
      selectedHour = hour;
      selectedMinute = minute;
    });
    await NotificationService().saveNotificationTime(hour, minute);
  }

  Future<void> _toggleSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() {
      if (key == 'notifications_enabled') _notificationsEnabled = value;
      if (key == 'sound_enabled') _soundEnabled = value;
      if (key == 'vibration_enabled') _vibrationEnabled = value;
    });
    if (key == 'notifications_enabled' && !value) {
      await NotificationService().cancelNotification();
    } else if (key == 'notifications_enabled' && value) {
      await NotificationService().scheduleDailyNotification(selectedHour, selectedMinute);
    }
  }

  void _showTimePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: DateTime(2023, 1, 1, selectedHour, selectedMinute),
                onDateTimeChanged: (DateTime newTime) {
                  setState(() {
                    selectedHour = newTime.hour;
                    selectedMinute = newTime.minute;
                  });
                },
              ),
            ),
            CupertinoButton(
              child: const Text("Готово"),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                _saveNotificationTime(selectedHour, selectedMinute);
                if (_notificationsEnabled) {
                  NotificationService().scheduleDailyNotification(selectedHour, selectedMinute);
                }
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Настройки уведомлений"),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CupertinoSettingsSection(),
    );
  }

  Widget CupertinoSettingsSection() {
  return CupertinoScrollbar(
    child: ListView(
      children: [
        CupertinoListSection.insetGrouped(
          header: Text("Уведомления"),
          children: [
            CupertinoListTile(
              title: Text("Разрешить уведомления"),
              trailing: CupertinoSwitch(
                value: _notificationsEnabled,
                onChanged: (value) => _toggleSetting('notifications_enabled', value),
              ),
            ),
            CupertinoListTile(
              title: Text("Звук уведомлений"),
              trailing: CupertinoSwitch(
                value: _soundEnabled,
                onChanged: _notificationsEnabled ? (value) => _toggleSetting('sound_enabled', value) : null,
              ),
            ),
            CupertinoListTile(
              title: Text("Вибрация при уведомлениях"),
              trailing: CupertinoSwitch(
                value: _vibrationEnabled,
                onChanged: _notificationsEnabled ? (value) => _toggleSetting('vibration_enabled', value) : null,
              ),
            ),
            CupertinoListTile(
                  title: Text("Время уведомлений"),
                  subtitle: Text("Выберите удобное время для записи мыслей."),
              trailing: Text(
                "${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}",
                style: TextStyle(color: CupertinoColors.systemGrey),
              ),
              onTap: _showTimePicker,
            ),
          ],
        ),
      ],
    ),
  );
 }
}