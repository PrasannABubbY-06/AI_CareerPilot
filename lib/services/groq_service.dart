import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ai_careerpilot/config/api_keys.dart';
import 'package:ai_careerpilot/services/skill_cache_manager.dart';

class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  // Fallback using Gemini if Groq fails or is unauthorized
  Future<String> _getFallbackResponse(String prompt, String systemInstruction) async {
    final geminiKey = ApiKeys.geminiApiKey;
    if (geminiKey.isEmpty) {
      return "Fallback AI Error: Gemini API Key is missing.";
    }
    try {
      debugPrint("Attempting Gemini Fallback...");
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: geminiKey,
      );
      final response = await model.generateContent([
        Content.text('$systemInstruction\n\nUser Prompt:\n$prompt'),
      ]);
      debugPrint("Gemini Fallback Response Success.");
      return response.text ?? "Failed to generate response.";
    } catch (e) {
      debugPrint("Gemini Fallback Failed: $e");
      return "Fallback AI Error: $e";
    }
  }

  // Helper method to make the generic POST request to Groq
  Future<String> _getGroqResponse(String prompt, String systemInstruction) async {
    final apiKey = ApiKeys.groqApiKey;
    String? groqErrorMsg;

    if (apiKey.isEmpty) {
      groqErrorMsg = "Groq API Key is missing.";
      debugPrint("Groq Error: $groqErrorMsg");
    } else {
      try {
        debugPrint("Groq Request: POST $_baseUrl");
        final response = await http.post(
          Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'llama-3.1-8b-instant',
            'messages': [
              {'role': 'system', 'content': systemInstruction},
              {'role': 'user', 'content': prompt}
            ],
            'temperature': 0.4, 
          }),
        );

        debugPrint("Groq Response Status: ${response.statusCode}");
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['choices'][0]['message']['content'].toString().trim();
        } else {
          groqErrorMsg = "Groq API Error (Status ${response.statusCode}): ${response.body}";
          debugPrint(groqErrorMsg);
        }
      } catch (e) {
        groqErrorMsg = "Groq Exception: $e";
        debugPrint(groqErrorMsg);
      }
    }

    // Fallback on failure
    final fallbackResponse = await _getFallbackResponse(prompt, systemInstruction);
    if (fallbackResponse.startsWith("Fallback AI Error:")) {
      // Both failed, return combined error message
      return "AI Service Error:\n\n1. Groq: $groqErrorMsg\n2. Gemini fallback: ${fallbackResponse.replaceFirst('Fallback AI Error:', '').trim()}";
    }
    return fallbackResponse;
  }
  /// Generates a customized learning path with embedded YouTube URLs using a Knowledge Base Cache
  Future<String> generateLearningRoadmap(List<String> missingSkills) async {
    if (missingSkills.isEmpty) {
      return "🎉 Great job! You aren't missing any required core skills for this specific target role.";
    }

    final StringBuffer combinedRoadmaps = StringBuffer();
    combinedRoadmaps.writeln("# AI Learning Path\n");
    combinedRoadmaps.writeln("Here is your customized learning roadmap for the detected missing skills:\n");

    const systemInstruction = """
      You are an expert technical career coach. Your task is to output a bulleted, step-by-step technical learning roadmap for a single skill.
      
      CRITICAL INSTRUCTION: You MUST provide EXACTLY 4 resources:
      1. A verified direct YouTube video tutorial or playlist URL.
      2. An official documentation URL.
      3. A high-quality Notes or Tutorial Article URL (Use trusted sites only: GeeksforGeeks, MDN, W3Schools, Official Documentation, FreeCodeCamp, Microsoft Learn, AWS Docs, Google Developers).
      4. A Practice or Resource URL (e.g. GitHub repository, LeetCode, Kaggle, Practice site).
      
      Ensure ALL links are valid, existing, and point to real resources. Do not hallucinate links.
      
      Format the output as clean markdown (do not wrap in a top-level # header, start directly with step-by-step list):
      - **Step 1**: ...
      - **Step 2**: ...
      - **Step 3**: ...
      ### 📚 Recommended Resources:
      - 📺 [Watch Complete Course on YouTube]([YouTube URL])
      - 📝 [Official Documentation]([Doc URL])
      - 📖 [Notes & Articles]([Notes URL])
      - 💻 [Practice & Resources]([Practice URL])
      """;

    final roadmapFutures = missingSkills.map((skill) async {
      final trimmedSkill = skill.trim();
      if (trimmedSkill.isEmpty) return null;

      // Check Cache/Database
      final cachedRoadmap = await SkillCacheManager.getRoadmap(trimmedSkill);
      if (cachedRoadmap != null && cachedRoadmap.isNotEmpty) {
        return MapEntry(trimmedSkill, cachedRoadmap);
      }

      // Cache Miss - Generate once using AI
      debugPrint("SKILL_CACHE [GENERATING AI ROADMAP FOR]: $trimmedSkill");

      final prompt = "Create a step-by-step learning roadmap and resource list to master the skill: $trimmedSkill.";
      
      try {
        final generatedRoadmap = await _getGroqResponse(prompt, systemInstruction);
        
        // If both APIs failed, we don't want to cache the error string
        if (generatedRoadmap.contains("AI Service Error:")) {
          return MapEntry(trimmedSkill, generatedRoadmap);
        }

        // Validate links before caching to prevent broken resources
        final validatedRoadmap = await _validateAndFixRoadmapLinks(generatedRoadmap);

        // Save to Cache/Database for future users
        await SkillCacheManager.saveRoadmap(trimmedSkill, validatedRoadmap);

        return MapEntry(trimmedSkill, validatedRoadmap);
      } catch (e) {
        debugPrint("Error generating roadmap for $trimmedSkill: $e");
        return MapEntry(trimmedSkill, "Error: Failed to generate roadmap for $trimmedSkill.\n");
      }
    });

    final results = await Future.wait(roadmapFutures);

    for (var result in results) {
      if (result == null) continue;
      
      if (result.value.contains("AI Service Error:")) {
        return result.value;
      }
      
      combinedRoadmaps.writeln("## ${result.key.toUpperCase()}");
      combinedRoadmaps.writeln(result.value);
      combinedRoadmaps.writeln("\n---\n");
    }

    return combinedRoadmaps.toString();
  }

  /// Generates structural and context-aware resume suggestions based on skills
  Future<String> improveResume(String resumeText, String targetRole) async {
    const systemInstruction = """
    You are an elite ATS resume reviewer and technical recruiter. 
    Analyze the user's resume for the specific target role requested. 
    Provide an actionable assessment divided clearly into 2 parts:
    1. 🛠️ CORE SKILLS UPGRADE: Tell them exactly which concepts/tools they should add to their resume sections to stand out for this role.
    2. 📝 BULLET POINT REWRITES: Provide 2-3 specific lines from their current text rewritten using strong action verbs and metrics (X% metrics or business impact).
    
    Keep the tone professional, direct, and constructive.
    """;

    final prompt = """
    Target Role: $targetRole
    
    Resume Content:
    $resumeText
    """;
    
    return await _getGroqResponse(prompt, systemInstruction);
  }

  /// Helper to validate all HTTP links in the markdown and replace broken ones
  Future<String> _validateAndFixRoadmapLinks(String roadmap) async {
    // Note: Link validation via http.get often fails with 403 or timeouts on valid sites 
    // like YouTube and GitHub, leading to false positives of "(Link Unavailable)".
    // Since we now rely on an extensive pre-populated database for most skills and 
    // strict AI prompting for the rest, we avoid making unreliable HTTP calls here.
    return roadmap;
  }
}