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
  late TextEditingController _tagsController;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note.text);
    _tagsController = TextEditingController();
    _tags = List.from(widget.note.tags);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tagsController.dispose();
    super.dispose();
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
          content: Column(
            children: [
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: _tagsController,
                placeholder: 'Введите тег',
                onSubmitted: (_) => _addTag(),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Отмена'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: const Text('Добавить'),
              onPressed: () {
                _addTag();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveNote() async {
    final updatedText = _controller.text.trim();
    if (updatedText.isNotEmpty) {
      final updatedNote = Diary(
        id: widget.note.id,
        text: updatedText,
        timestamp: widget.note.timestamp,
        tags: _tags,
      );
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
          onPressed: _saveNote,
          child: const Text(
            'Сохранить',
            style: TextStyle(color: CupertinoColors.activeBlue),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CupertinoTextField(
                controller: _controller,
                placeholder: 'Редактировать заметку...',
                padding: const EdgeInsets.all(16),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: null,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Теги:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _showTagDialog,
                        child: const Text('Добавить тег'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(tag),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _removeTag(tag),
                            child: const Icon(
                              CupertinoIcons.xmark_circle_fill,
                              size: 18,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}