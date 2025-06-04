import 'package:flutter/cupertino.dart';
import 'package:stoic_quotes_app/models/models.dart';
import 'package:stoic_quotes_app/services/database/database_services.dart';

class EditNoteScreen extends StatefulWidget {
  final Diary note;

  const EditNoteScreen({super.key, required this.note});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final updatedText = _controller.text.trim();
    if (updatedText.isNotEmpty) {
      final updatedNote = widget.note.copyWith(text: updatedText);
      await DatabaseService().updateDiaryEntry(updatedNote); // Обновляем запись в базе данных
      Navigator.pop(context, updatedNote); // Возвращаемся на предыдущий экран
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Редактировать заметку'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveNote, // Сохраняем изменения
          child: const Text(
            'Сохранить',
            style: TextStyle(color: CupertinoColors.activeBlue),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CupertinoTextField(
            controller: _controller,
            placeholder: 'Редактировать заметку...',
            padding: const EdgeInsets.all(12.0),
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: null,
          ),
        ),
      ),
    );
  }
}