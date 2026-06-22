import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ai_careerpilot/config/api_keys.dart';

import '../models/question_model.dart';
import '../models/result_model.dart';

class SkillAiService {
  late final GenerativeModel model;

  SkillAiService() {
    model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: ApiKeys.geminiApiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json', // Forces Gemini to reply in pure JSON format
      ),
    );
  }

  DateTime? _lastCallTime;
  static const int cooldownSeconds = 30;

  int _callCount = 0;
  static const int maxCallsPerSession = 5;

  final Map<String, List<QuestionModel>> _skillCache = {};

  Future<List<QuestionModel>> generateQuestions(String skill) async {
    try {
      if (_skillCache.containsKey(skill)) {
        return _skillCache[skill]!;
      }

      if (_callCount >= maxCallsPerSession) {
        throw Exception("AI usage limit reached.");
      }

      if (_lastCallTime != null) {
        final diff = DateTime.now().difference(_lastCallTime!).inSeconds;

        if (diff < cooldownSeconds) {
          throw Exception(
            "Please wait ${cooldownSeconds - diff} seconds.",
          );
        }
      }

      final prompt = """
You are an expert technical interviewer.

Generate exactly 10 multiple-choice interview questions for the skill: $skill

Rules:
- 4 Beginner
- 3 Intermediate
- 3 Advanced
- 4 options each
- Only one correct answer

Return ONLY valid JSON array containing objects matching this schema structure:
[
  {
    "question": "Sample Question",
    "options": ["A","B","C","D"],
    "answer": 0,
    "level": "beginner"
  }
]
""";

      final response = await model.generateContent([
        Content.text(prompt),
      ]);

      _lastCallTime = DateTime.now();
      _callCount++;

      final rawText = response.text ?? "";

      final cleaned =
          rawText.replaceAll("```json", "").replaceAll("```", "").trim();

      if (cleaned.isEmpty) {
        throw Exception("Empty response");
      }

      final decoded = jsonDecode(cleaned);

      if (decoded is! List) {
        throw Exception("Invalid JSON format");
      }

      final questions = decoded.map<QuestionModel>((e) {
        return QuestionModel(
          question: e["question"] ?? "",
          options: List<String>.from(e["options"] ?? []),
          correctIndex: e["answer"] ?? 0,
          level: e["level"] ?? "beginner",
        );
      }).toList();

      _skillCache[skill] = questions;

      return questions;
    } catch (e) {
      debugPrint("Gemini Error: $e");
      return _fallbackQuestions(skill);
    }
  }

  List<QuestionModel> _fallbackQuestions(String skill) {
    return [
      QuestionModel(
        question: "What is $skill mainly used for?",
        options: const ["Frontend", "Backend", "Both", "None"],
        correctIndex: 2,
        level: "beginner",
      ),
      QuestionModel(
        question: "Which concept is important in $skill?",
        options: const ["Basics", "Advanced", "OOP", "All"],
        correctIndex: 3,
        level: "beginner",
      ),
      QuestionModel(
        question: "Which project best demonstrates $skill?",
        options: const [
          "Calculator",
          "Portfolio",
          "Real-time App",
          "Static Page"
        ],
        correctIndex: 2,
        level: "intermediate",
      ),
      QuestionModel(
        question: "How confident are you in debugging $skill?",
        options: const ["Low", "Medium", "Good", "Excellent"],
        correctIndex: 2,
        level: "intermediate",
      ),
      QuestionModel(
        question: "Which level best describes your $skill knowledge?",
        options: const ["Beginner", "Intermediate", "Advanced", "Expert"],
        correctIndex: 1,
        level: "advanced",
      ),
    ];
  }

  ResultModel calculate({
    required int total,
    required int correct,
    required int beginner,
    required int intermediate,
    required int advanced,
  }) {
    final percent = total == 0 ? 0.0 : (correct / total) * 100;

    final beginnerScore = (beginner / 4) * 100;
    final intermediateScore = (intermediate / 3) * 100;
    final advancedScore = (advanced / 3) * 100;

    return ResultModel(
      total: total,
      correct: correct,
      percentage: percent,
      skillScores: {
        "Beginner": beginnerScore,
        "Intermediate": intermediateScore,
        "Advanced": advancedScore,
        "Accuracy": percent,
        "Problem Solving": (percent - 5).clamp(0, 100).toDouble(),
        "Debugging": (percent - 2).clamp(0, 100).toDouble(),
        "Architecture": (percent - 3).clamp(0, 100).toDouble(),
      },
    );
  }
}
