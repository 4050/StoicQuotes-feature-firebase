import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:stoic_quotes_app/models/models.dart';
import 'package:stoic_quotes_app/view/view.dart';


class ViewNoteScreen extends StatefulWidget {
  final Diary note;

  const ViewNoteScreen({super.key, required this.note});

  @override
  _ViewNoteScreenState createState() => _ViewNoteScreenState();
}

class _ViewNoteScreenState extends State<ViewNoteScreen> {
  late Diary _note;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
  }

  Future<void> _editNote() async {
    final updatedNote = await Navigator.push<Diary>(
      context,
      CupertinoPageRoute(
        builder: (context) => EditNoteScreen(note: _note),
      ),
    );

    if (updatedNote != null) {
      setState(() {
        _note = updatedNote;
      });
    }
  }

  Widget _buildTags() {
    if (_note.tags.isEmpty) {
      return const Text(
        'Нет тегов',
        style: TextStyle(color: CupertinoColors.systemGrey),
      );
    }
    
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _note.tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          tag,
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 14,
          ),
        ),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, d MMMM').format(_note.timestamp);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Заметка'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _editNote,
          child: const Icon(CupertinoIcons.pencil),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _note.text,
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 10),
              Text(
                formattedDate,
                style: const TextStyle(fontSize: 14.0, color: CupertinoColors.inactiveGray),
              ),
              if (_note.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Теги:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTags(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}