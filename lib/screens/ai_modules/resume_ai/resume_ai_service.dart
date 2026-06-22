import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ResumeAiService {

  // =====================================================
  // EXTRACT TEXT FROM PDF (FIXED)
  // =====================================================
  Future<String> extractText(File file) async {
    try {
      final bytes = await file.readAsBytes();

      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);

      String text = "";

      for (int i = 0; i < document.pages.count; i++) {
        text += extractor.extractText(
          startPageIndex: i,
          endPageIndex: i,
        );
      }

      document.dispose();
      return text;
    } catch (e) {
      return "Error reading PDF: $e";
    }
  }

  // =====================================================
  // ATS SCORE
  // =====================================================
  int atsScore(String text) {
    final keywords = [
      "flutter",
      "dart",
      "firebase",
      "api",
      "project",
      "experience"
    ];

    int score = 0;

    for (final k in keywords) {
      if (text.toLowerCase().contains(k)) {
        score += 10;
      }
    }

    return score.clamp(0, 100);
  }

  // =====================================================
  // MISSING KEYWORDS
  // =====================================================
  List<String> missingKeywords(String text) {
    final required = [
      "flutter",
      "api",
      "state management",
      "firebase",
      "github"
    ];

    return required
        .where((k) => !text.toLowerCase().contains(k))
        .toList();
  }

  // =====================================================
  // WEAK SECTIONS
  // =====================================================
  List<String> weakSections(String text) {
    List<String> weak = [];

    if (!text.toLowerCase().contains("project")) {
      weak.add("Projects section missing");
    }

    if (!text.toLowerCase().contains("experience")) {
      weak.add("Experience not detailed");
    }

    if (!text.toLowerCase().contains("skills")) {
      weak.add("Skills section weak");
    }

    return weak;
  }

  // =====================================================
  // SUGGESTIONS
  // =====================================================
  List<String> suggestions(String text) {
    return [
      "Add more real projects",
      "Include GitHub links",
      "Improve ATS keywords",
      "Add measurable achievements"
    ];
  }
}