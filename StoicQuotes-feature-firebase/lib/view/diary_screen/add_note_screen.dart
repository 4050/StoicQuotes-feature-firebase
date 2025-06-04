import 'package:flutter/cupertino.dart';
import 'package:stoic_quotes_app/services/services.dart';
import 'package:stoic_quotes_app/models/models.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});
  
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final List<String> _tags = [];

  // Используем DatabaseService для вставки записи дневника
  Future<void> _addNote() async {
    if (_controller.text.trim().isNotEmpty) {
      final diary = Diary(
        id: '',
        text: _controller.text,
        tags: _tags, // Добавляем теги
        timestamp: DateTime.now(), 
      );
      await DatabaseService().insertDiaryEntry(diary);
      Navigator.pop(context);
    }
  }

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
      _tagsController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

 void _showTagDialog() {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text('Добавить тег'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CupertinoTextField(
            controller: _tagsController,
            placeholder: 'Введите тег...',
            onSubmitted: (_) {
              _addTag();
              Navigator.of(context).pop();
            },
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              _addTag();
              Navigator.of(context).pop();
            },
            child: const Text('Добавить'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
        ],
      );
    },
  );
}

@override
Widget build(BuildContext context) {
  return CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(
      middle: const Text('Новая заметка'),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _addNote,
        child: const Text(
          'Сохранить',
          style: TextStyle(color: CupertinoColors.activeBlue),
        ),
      ),
    ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: _controller,
                  placeholder: 'Введите вашу мысль...',
                  padding: const EdgeInsets.all(12.0),
                  maxLines: null,
                  expands: true, // Поле занимает весь доступный экран
                  textAlignVertical: TextAlignVertical.top,
                  decoration: null, // Убираем рамку
                  textInputAction: TextInputAction.done, // Кнопка "Готово" на клавиатуре
                  keyboardAppearance: Brightness.light,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _showTagDialog,
                    child: const Icon(CupertinoIcons.tag),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: _tags
                    .map((tag) => _buildCupertinoTag(tag))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
  );
}

Widget _buildCupertinoTag(String tag) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
    margin: const EdgeInsets.only(bottom: 8.0),
    decoration: BoxDecoration(
      color: CupertinoColors.systemGrey5,
      borderRadius: BorderRadius.circular(16.0),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(tag, style: const TextStyle(color: CupertinoColors.black)),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _removeTag(tag),
          child: const Icon(
            CupertinoIcons.clear_circled,
            size: 18,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    ),
  );
}
}