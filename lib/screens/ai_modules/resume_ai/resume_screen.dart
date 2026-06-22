import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'resume_ai_service.dart';

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  final service = ResumeAiService();

  int score = 0;
  List<String> missing = [];
  List<String> weak = [];
  List<String> tips = [];

  Future<void> pickResume() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    final file = File(result.files.single.path!);

    final text = await service.extractText(file);

    setState(() {
      score = service.atsScore(text);
      missing = service.missingKeywords(text);
      weak = service.weakSections(text);
      tips = service.suggestions(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Resume Analyzer")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickResume,
              child: const Text("Upload Resume"),
            ),

            const SizedBox(height: 20),

            Text("ATS Score: $score"),

            const SizedBox(height: 20),

            Text("Missing Keywords: ${missing.join(", ")}"),

            Text("Weak Areas: ${weak.join(", ")}"),

            Text("Suggestions: ${tips.join(", ")}"),
          ],
        ),
      ),
    );
  }
}