import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stoic_quotes_app/models/models.dart';

class ViewNoteScreen extends StatelessWidget {
  final Diary note;

  const ViewNoteScreen({super.key, required this.note});

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
          child: Padding(
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
        body: Padding(
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
            ],
          ),
        ),
      );
    }
  }
}