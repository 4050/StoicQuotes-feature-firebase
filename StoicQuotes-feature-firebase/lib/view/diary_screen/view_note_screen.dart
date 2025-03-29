import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stoic_quotes_app/models/models.dart';

class ViewNoteScreen extends StatelessWidget {
  final Diary note;

  const ViewNoteScreen({super.key, required this.note});

  Widget _buildTags() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: note.tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Platform.isIOS 
              ? CupertinoColors.systemGrey5 
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: Platform.isIOS 
                ? CupertinoColors.black 
                : Colors.black87,
          ),
        ),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      String formattedDate = DateFormat('EEEE, d MMMM').format(note.timestamp);
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Заметка'),
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(CupertinoIcons.back),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.text,
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 10),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 14.0, color: CupertinoColors.inactiveGray),
                ),
                if (note.tags.isNotEmpty) ...[
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
    } else {
      String formattedDate = DateFormat('EEEE, d MMMM').format(note.timestamp);
      return Scaffold(
        appBar: AppBar(
          title: const Text('Заметка'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.text,
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 10),
              Text(
                formattedDate,
                style: const TextStyle(fontSize: 14.0, color: Colors.grey),
              ),
              if (note.tags.isNotEmpty) ...[
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
      );
    }
  }
}