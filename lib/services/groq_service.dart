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

    for (int i = 0; i < missingSkills.length; i++) {
      final skill = missingSkills[i].trim();
      if (skill.isEmpty) continue;

      // Check Cache/Database
      final cachedRoadmap = await SkillCacheManager.getRoadmap(skill);
      if (cachedRoadmap != null && cachedRoadmap.isNotEmpty) {
        combinedRoadmaps.writeln("## ${skill.toUpperCase()}");
        combinedRoadmaps.writeln(cachedRoadmap);
        combinedRoadmaps.writeln("\n---\n");
        continue;
      }

      // Cache Miss - Generate once using AI
      debugPrint("SKILL_CACHE [GENERATING AI ROADMAP FOR]: $skill");
      const systemInstruction = """
      You are an expert technical career coach. Your task is to output a bulleted, step-by-step technical learning roadmap for a single skill.
      
      CRITICAL INSTRUCTION: You MUST provide:
      1. A step-by-step roadmap containing 3-5 clear steps.
      2. A verified direct YouTube video tutorial or playlist URL (e.g. https://www.youtube.com/watch?v=... or https://www.youtube.com/playlist?list=...). Do NOT output a search results page link.
      3. An official documentation URL.
      4. A high-quality GitHub repository URL related to learning or mastering this skill.
      
      Format the output as clean markdown (do not wrap in a top-level # header, start directly with step-by-step list):
      - **Step 1**: ...
      - **Step 2**: ...
      - **Step 3**: ...
      ### 📚 Recommended Resources:
      - 📺 [Watch Complete Course on YouTube]([YouTube URL])
      - 📝 [Official Documentation]([Doc URL])
      - 💻 [GitHub Repository]([GitHub URL])
      """;

      final prompt = "Create a step-by-step learning roadmap and resource list to master the skill: $skill.";
      
      try {
        final generatedRoadmap = await _getGroqResponse(prompt, systemInstruction);
        
        // If both APIs failed, we don't want to cache the error string
        if (generatedRoadmap.contains("AI Service Error:")) {
          return generatedRoadmap;
        }

        // Save to Cache/Database for future users
        await SkillCacheManager.saveRoadmap(skill, generatedRoadmap);

        combinedRoadmaps.writeln("## ${skill.toUpperCase()}");
        combinedRoadmaps.writeln(generatedRoadmap);
        combinedRoadmaps.writeln("\n---\n");
      } catch (e) {
        debugPrint("Error generating roadmap for $skill: $e");
        combinedRoadmaps.writeln("## ${skill.toUpperCase()}");
        combinedRoadmaps.writeln("Error: Failed to generate roadmap for $skill.\n");
        combinedRoadmaps.writeln("\n---\n");
      }
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
}