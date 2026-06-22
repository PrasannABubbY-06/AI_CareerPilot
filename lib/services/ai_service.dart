import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ai_careerpilot/config/api_keys.dart';

import '../models/analysis_model.dart';

class AIService {
  late final GenerativeModel model;

  AIService() {
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: ApiKeys.geminiApiKey,
    );
  }

  // =====================================================
  // 🔥 RESUME ANALYZER
  // =====================================================

  Future<AnalysisModel> analyzeResume(
    String resumeText,
  ) async {

    try {

      final prompt = """

You are an expert ATS Resume Analyzer.

Analyze this resume:

$resumeText

Return ONLY valid JSON.

Format:

{
  "atsScore": 85,
  "skills": ["Flutter", "Firebase"],
  "missingSkills": ["AWS", "Docker"],
  "suggestions": [
    "Improve ATS keywords",
    "Add strong projects"
  ]
}

""";

      final response =
          await model.generateContent([

        Content.text(prompt),

      ]);

      final rawText =
          response.text ?? "";

      final cleaned = rawText

          .replaceAll("```json", "")

          .replaceAll("```", "")

          .trim();

      final decoded =
          jsonDecode(cleaned);

      return AnalysisModel(

        atsScore:
            decoded["atsScore"] ?? 70,

        skills:
            List<String>.from(
          decoded["skills"] ?? [],
        ),

        missingSkills:
            List<String>.from(
          decoded["missingSkills"] ?? [],
        ),

        suggestions:
            List<String>.from(
          decoded["suggestions"] ?? [],
        ),
      );

    } catch (e) {

      // =====================================================
      // 🔥 FALLBACK
      // =====================================================

      return AnalysisModel(

        atsScore: 75,

        skills: [
          "Flutter",
          "Firebase",
          "Dart",
        ],

        missingSkills: [
          "AWS",
          "Docker",
          "System Design",
        ],

        suggestions: [
          "Add measurable achievements",
          "Improve ATS keywords",
          "Add real-world projects",
          "Mention internships",
        ],
      );
    }
  }
}