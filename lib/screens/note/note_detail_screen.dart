import 'package:flutter/material.dart';

class NoteDetailScreen extends StatelessWidget {
  final String title;
  final String content;

  const NoteDetailScreen(
      {super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B61EA),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF2F5FA),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Image for the Note

              // Title of the Note
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B61EA),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Content Details of the Note
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
