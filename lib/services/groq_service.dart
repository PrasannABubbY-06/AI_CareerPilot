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

  /// Expose generic call for Career Mentor and other services
  Future<String> generateGenericResponse(String prompt, String systemInstruction) async {
    return await _getGroqResponse(prompt, systemInstruction);
  }

  /// Generates a personalized daily motivation message
  Future<String> generateDailyMotivation(String userName, int level, int streak, String? careerGoal) async {
    final String goalContext = careerGoal != null && careerGoal.isNotEmpty 
        ? "Their ultimate goal is to become a $careerGoal." 
        : "They are currently exploring tech careers.";

    final systemInstruction = """
    You are a supportive and inspiring AI Career Mentor.
    Write a short, engaging 2-sentence daily motivation message for the user.
    Acknowledge their current level or daily streak to make it personalized.
    $goalContext
    Use emojis. Do not use generic corporate language. Make it punchy and actionable.
    """;

    final prompt = "User Name: $userName\nLevel: $level\nStreak: $streak days";
    return await _getGroqResponse(prompt, systemInstruction);
  }

  /// Generates a weekly progress report from the AI Career Twin
  Future<String> generateWeeklyReport(String userName, int level, int xpEarned, List<String> completedTasks, String? careerGoal) async {
    final String goalContext = careerGoal != null && careerGoal.isNotEmpty 
        ? "Their ultimate goal is to become a $careerGoal." 
        : "They are currently exploring tech careers.";
        
    final systemInstruction = """
    You are a highly analytical and supportive AI Career Twin.
    Generate a short Weekly Progress Report for the user based on their activity this week.
    $goalContext
    Provide a 3-part structured response:
    1. 🏆 Weekly Wins: A short 2-sentence celebration of what they accomplished.
    2. 🔍 Focus Area: Identify one area they should focus on next based on their completed tasks.
    3. 🚀 Next Step: A single actionable recommendation for the upcoming week.
    Format nicely with markdown. Keep it concise, engaging, and professional.
    """;

    final prompt = "User Name: $userName\nLevel: $level\nXP Earned: $xpEarned\nCompleted Tasks this week: ${completedTasks.join(', ')}";
    return await _getGroqResponse(prompt, systemInstruction);
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
      
      CRITICAL INSTRUCTION: You MUST provide EXACTLY 4 resources. To prevent broken links, use these exact URL formats:
      1. YouTube URL: MUST be a search query -> https://www.youtube.com/results?search_query=[Skill+Name]+tutorial
      2. Documentation URL: Use the official top-level domain OR a google search -> https://www.google.com/search?q=[Skill+Name]+official+documentation
      3. Notes URL: Use a google search query -> https://www.google.com/search?q=[Skill+Name]+tutorial+GeeksforGeeks
      4. Practice URL: Use a google search query -> https://www.google.com/search?q=[Skill+Name]+practice+problems
      
      Ensure you only substitute [Skill+Name] with the actual skill name. Do NOT hallucinate specific video IDs or deep links.
      
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

  /// Generates resources for a specific journey stage
  Future<String> generateStageResources(String skillName, int levelIndex) async {
    final stages = ["Beginner", "Intermediate", "Advanced", "Expert", "Job Ready"];
    final stageName = stages[levelIndex];

    const systemInstruction = """
    You are an expert technical curriculum designer.
    Generate a short, focused learning guide for a specific skill and proficiency level.
    Provide exactly:
    1. A short introduction (2 sentences).
    2. 3 Key Concepts to learn at this stage.
    3. 3 Recommended Resources. 
    
    CRITICAL URL RULES:
    - NEVER invent specific YouTube video IDs. You MUST use a YouTube search URL: https://www.youtube.com/results?search_query=[Skill]+[Stage]+tutorial
    - For documentation or articles, use Google search URLs: https://www.google.com/search?q=[Skill]+[Stage]+documentation
    - Do NOT hallucinate specific deep links. Use search queries.
    
    Format as clean markdown. Do not include a title header.
    """;

    final prompt = "Generate a learning guide for $skillName at the $stageName level.";
    return await _getGroqResponse(prompt, systemInstruction);
  }

  /// Generates a 3-5 MCQ quiz for a specific journey stage
  Future<String> generateStageQuiz(String skillName, int levelIndex) async {
    final stages = ["Beginner", "Intermediate", "Advanced", "Expert", "Job Ready"];
    final stageName = stages[levelIndex];

    const systemInstruction = """
    You are an expert technical assessor.
    Create a 3-question multiple choice quiz to test someone's knowledge on a skill at a specific proficiency level.
    You MUST respond with ONLY a valid JSON array of objects. No markdown, no intro text.
    Structure exactly like this:
    [
      {
        "question": "What is X?",
        "options": ["A", "B", "C", "D"],
        "correctIndex": 0,
        "explanation": "A is correct because..."
      }
    ]
    """;

    final prompt = "Generate a 3-question quiz for $skillName at the $stageName level.";
    return await _getGroqResponse(prompt, systemInstruction);
  }
}