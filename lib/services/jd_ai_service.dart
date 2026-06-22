import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ai_careerpilot/config/api_keys.dart';

class JDAiService {
  late final GenerativeModel model;

  JDAiService() {
    model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: ApiKeys.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topP: 0.9,
        topK: 40,
        maxOutputTokens: 2048,
      ),
    );
  }

  // =====================================================
  // AI ANALYSIS
  // =====================================================

  Future<Map<String, dynamic>>
      analyzeResumeAndJD({

    required String resumeText,
    required String jdText,

  }) async {

    try {

      // ================= VALIDATION =================

      if (resumeText.trim().isEmpty) {

        return {

          "matchScore": 0,

          "resumeStrength":
              "Resume text is empty",

          "requiredSkills": [],

          "missingSkills": [],

          "eligibleRoles": [],

          "suggestions": [
            "Upload proper resume"
          ],

          "resumeSummary":
              "Could not read resume content",
        };
      }

      // ================= PROMPT =================

      final prompt = """

You are an ATS Resume Analyzer AI.

Analyze the RESUME and JOB DESCRIPTION.

================ RESUME ================

$resumeText

================ JOB DESCRIPTION ================

$jdText

IMPORTANT:

1. Return ONLY valid JSON
2. No markdown
3. No extra text
4. No explanation
5. Never leave fields empty
6. Keep response professional

Return format:

{
  "matchScore": 75,
  "resumeStrength": "Good frontend skills",
  "requiredSkills": [
    "Flutter",
    "Firebase"
  ],
  "missingSkills": [
    "Docker"
  ],
  "eligibleRoles": [
    "Flutter Developer"
  ],
  "suggestions": [
    "Improve ATS keywords"
  ],
  "resumeSummary":
      "Candidate has frontend development skills."
}

""";

      // ================= GEMINI RESPONSE =================

      final response =
          await model.generateContent([

        Content.text(prompt),

      ]);

      final rawText =
          response.text ?? "";

      debugPrint(
        "RAW RESPONSE:",
      );

      debugPrint(rawText);

      // ================= EMPTY RESPONSE =================

      if (rawText.trim().isEmpty) {

        return {

          "matchScore": 50,

          "resumeStrength":
              "AI returned empty response",

          "requiredSkills": [],

          "missingSkills": [],

          "eligibleRoles": [],

          "suggestions": [
            "Try again"
          ],

          "resumeSummary":
              "Could not analyze resume",
        };
      }

      // ================= CLEAN RESPONSE =================

      String cleaned = rawText
          .replaceAll("```json", "")
          .replaceAll("```", "")
          .trim();

      // ================= SAFE JSON EXTRACTION =================

      final start =
          cleaned.indexOf("{");

      final end =
          cleaned.lastIndexOf("}");

      if (start != -1 &&
          end != -1) {

        cleaned = cleaned.substring(
          start,
          end + 1,
        );
      }

      debugPrint(
        "CLEANED JSON:",
      );

      debugPrint(cleaned);

      // ================= SAFE JSON DECODE =================

      Map<String, dynamic> decoded = {};

      try {

        decoded = jsonDecode(cleaned);

      } catch (e) {

        debugPrint("JSON ERROR: $e");

        return {

          "matchScore": 50,

          "resumeStrength":
              "AI returned invalid response",

          "requiredSkills": [],

          "missingSkills": [],

          "eligibleRoles": [],

          "suggestions": [
            "Try again"
          ],

          "resumeSummary":
              "Could not analyze",
        };
      }

      // ================= RETURN FINAL DATA =================

      return {

        "matchScore":
            decoded["matchScore"] ?? 0,

        "resumeStrength":
            decoded["resumeStrength"] ??
                "Analysis completed",

        "requiredSkills":
            List<String>.from(
          decoded["requiredSkills"] ?? [],
        ),

        "missingSkills":
            List<String>.from(
          decoded["missingSkills"] ?? [],
        ),

        "eligibleRoles":
            List<String>.from(
          decoded["eligibleRoles"] ?? [],
        ),

        "suggestions":
            List<String>.from(
          decoded["suggestions"] ?? [],
        ),

        "resumeSummary":
            decoded["resumeSummary"] ??
                "Resume analyzed successfully",
      };

    } catch (e) {

      debugPrint(
        "JD AI ERROR: $e",
      );

      return {

        "matchScore": 50,

        "resumeStrength":
            "AI analysis failed",

        "requiredSkills": [],

        "missingSkills": [],

        "eligibleRoles": [],

        "suggestions": [
          "Try again later"
        ],

        "resumeSummary":
            "Could not analyze resume",
      };
    }
  }
}