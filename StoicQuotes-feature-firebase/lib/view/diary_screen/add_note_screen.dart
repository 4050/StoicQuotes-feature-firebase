import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNoteScreen extends StatefulWidget {
   const AddNoteScreen({super.key});
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _controller = TextEditingController();
  final CollectionReference _notesCollection = FirebaseFirestore.instance.collection('diary_notes');

  void _addNote() {
    if (_controller.text.isNotEmpty) {
      _notesCollection.add({'text': _controller.text, 'timestamp': Timestamp.now()});
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить заметку'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Введите вашу мысль...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addNote,
              child: Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}