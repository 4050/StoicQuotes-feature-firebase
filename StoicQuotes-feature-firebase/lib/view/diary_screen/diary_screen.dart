import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:stoic_quotes_app/services/services.dart';
import 'package:stoic_quotes_app/view/view.dart';
import 'package:stoic_quotes_app/models/models.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});
  
  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final CollectionReference _notesCollection =
      DatabaseService().firebaseDiaryCollection;

  void _navigateToAddNoteScreen() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const AddNoteScreen()),
    );
  }

  void _navigateToViewNoteScreen(Diary note) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => ViewNoteScreen(note: note)),
    );
  }

  Widget _buildTagsList(List<String> tags) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '#$tag',
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
      )).toList(),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Удалить запись?"),
        content: const Text("Вы уверены, что хотите удалить этот дневник?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Отмена"),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Удалить"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      _deleteNote(id);
    }
  }

  void _deleteNote(String id) async {
    await DatabaseService().deleteDiaryEntry(id);
  }

  Widget _buildNotesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _notesCollection.orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Ошибка загрузки данных'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Нет записей',
          style: TextStyle(
            fontSize: 18,
            color: CupertinoColors.inactiveGray,
              ),
            ),
          );
        }
        final notes = snapshot.data!.docs;
        return CupertinoScrollbar(
          child: ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              var note = notes[index];
              DateTime timestamp = (note['timestamp'] as Timestamp).toDate();
              String formattedDate = DateFormat('EEEE, d MMMM').format(timestamp);
              String noteText = note['text'];

              Diary diary = Diary(
                id: note.id,
                text: noteText,
                timestamp: timestamp,
                tags: List<String>.from(note['tags'] ?? []),
              );

              return CupertinoListTile(
                title: Text(
                  noteText,
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 14.0, color: CupertinoColors.inactiveGray),
                    ),
                    if (diary.tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildTagsList(diary.tags),
                    ],
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _confirmDelete(note.id),
                  child: const Icon(
                    CupertinoIcons.trash,
                    color: CupertinoColors.destructiveRed,
                  ),
                ),
                onTap: () => _navigateToViewNoteScreen(diary),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Дневник'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _navigateToAddNoteScreen,
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: _buildNotesList(),
      ),
    );
  }
}