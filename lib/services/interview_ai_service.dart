import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ai_careerpilot/config/api_keys.dart';

class InterviewAiService {
  late final GenerativeModel model;

  InterviewAiService() {
    model = GenerativeModel(
      model: "gemini-1.5-flash",
      apiKey: ApiKeys.geminiApiKey,
    );
  }

  // =====================================================
  // GENERATE AI QUESTIONS
  // =====================================================

  Future<List<String>> generateQuestions({

    required String role,

    required String level,

  }) async {

    try {

      final prompt = """

You are an expert technical interviewer.

Generate 12 UNIQUE interview questions.

Role: $role

Difficulty Level: $level

Question Requirements:

1. Technical concepts
2. Real-world project scenarios
3. Debugging problems
4. HR interview questions
5. Problem solving questions
6. Architecture/design questions
7. Communication questions

Rules:
- Questions must be professional
- Questions must match the role exactly
- Questions should NOT repeat
- Return ONLY valid JSON array
- No markdown
- No explanation

Example Format:

[
  "Question 1",
  "Question 2",
  "Question 3"
]

""";

      final response =
          await model.generateContent([

        Content.text(prompt),

      ]);

      final rawText =
          response.text ?? "";

      // =====================================================
      // CLEAN RESPONSE
      // =====================================================

      final cleaned = rawText

          .replaceAll("```json", "")

          .replaceAll("```", "")

          .trim();

      if (cleaned.isEmpty) {

        throw Exception(
          "Empty Gemini response",
        );
      }

      final decoded =
          jsonDecode(cleaned);

      if (decoded is! List) {

        throw Exception(
          "Invalid JSON format",
        );
      }

      return List<String>.from(
        decoded,
      );

    } catch (e) {

      debugPrint(
        "Interview AI Error: $e",
      );

      // =====================================================
      // FALLBACK QUESTIONS
      // =====================================================

      return [

        "Tell me about yourself.",

        "Why did you choose this $role."

        "Explain one project you built related to $role.",

        "What challenges did you face while developing projects?",

        "How do you solve bugs in applications?",

        "Explain a difficult technical problem you solved.",

        "How do you optimize application performance?",

        "Describe your teamwork experience.",

        "Why are you interested in $role?",

        "How do you learn new technologies quickly?",

        "If selected what would you aim to improve or change in our current process within the first 3 months",

        "Where do you see yourself in the next 5 years?",
      ];
    }
  }

  // =====================================================
  // CONFIDENCE ANALYSIS
  // =====================================================

  int analyzeConfidence(
    String answer,
  ) {

    int score = 30;

    final lowerAnswer =
        answer.toLowerCase();

    // =====================================================
    // ANSWER LENGTH
    // =====================================================

    if (answer.length > 30) {
      score += 10;
    }

    if (answer.length > 80) {
      score += 15;
    }

    if (answer.length > 150) {
      score += 10;
    }

    // =====================================================
    // PROFESSIONAL WORDS
    // =====================================================

    if (lowerAnswer.contains(
      "project",
    )) {
      score += 10;
    }

    if (lowerAnswer.contains(
      "experience",
    )) {
      score += 10;
    }

    if (lowerAnswer.contains(
      "team",
    )) {
      score += 5;
    }

    if (lowerAnswer.contains(
      "develop",
    )) {
      score += 5;
    }

    if (lowerAnswer.contains(
      "solution",
    )) {
      score += 5;
    }

    if (lowerAnswer.contains(
      "client",
    )) {
      score += 5;
    }

    if (lowerAnswer.contains(
      "api",
    )) {
      score += 5;
    }

    if (lowerAnswer.contains(
      "database",
    )) {
      score += 5;
    }

    // =====================================================
    // LIMIT SCORE
    // =====================================================

    if (score > 100) {
      score = 100;
    }

    return score;
  }

  // =====================================================
  // AI FEEDBACK
  // =====================================================

  String generateFeedback({

    required String answer,

    required int score,

  }) {

    if (answer.trim().isEmpty) {

      return
          "You did not provide enough answer. Try explaining your thoughts clearly with examples.";
    }

    if (score >= 85) {

      return
          "Excellent answer. Your communication and confidence are strong. Keep giving real-world project examples.";
    }

    else if (score >= 65) {

      return
          "Good answer. Try improving technical depth and explain concepts more clearly.";
    }

    else if (score >= 45) {

      return
          "Average response. Improve confidence, communication, and technical explanation.";
    }

    else {

      return
          "Your answer needs improvement. Practice speaking clearly and provide structured technical answers.";
    }
  }
}
