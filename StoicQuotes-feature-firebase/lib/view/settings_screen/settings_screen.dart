import 'package:flutter/cupertino.dart';
import 'package:stoic_quotes_app/view/view.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  void initState() {
    super.initState();
  }


  void _navigateToNotificationSettings() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => NotificationSettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Настройки"),
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
            header: const Text("Настройки"),
            children: [
              CupertinoListTile(
                title: const Text("Настройка уведомлений"),
                trailing: const Icon(CupertinoIcons.forward),
                onTap: _navigateToNotificationSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
