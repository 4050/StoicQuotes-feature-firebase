import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_note_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});
  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final CollectionReference _notesCollection = FirebaseFirestore.instance.collection('diary_notes');

  void _navigateToAddNoteScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNoteScreen()),
    );
  }

  void _deleteNote(String id) async {
    await _notesCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Дневник'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notesCollection.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки данных'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Нет записей'));
          }
          final notes = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              var note = notes[index];
              return Card(
                child: ListTile(
                  title: Text(note['text']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteNote(note.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddNoteScreen,
        child: Icon(Icons.add),
      ),
    );
  }
}
