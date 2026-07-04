import 'package:flutter/foundation.dart';
import 'groq_service.dart';
import 'skill_cache_manager.dart';

class CareerMentorService {
  final GroqService _groqService = GroqService();

  Future<String> generateCareerReport({
    required String education,
    required String skills,
    required String interests,
    required String strengths,
    required String weaknesses,
    required String dreamCareer,
    required String industry,
    required String sectorPreference, // Govt, Private, Business
  }) async {
    // 1. Generate unique hash for these exact inputs
    final profileData = {
      'education': education,
      'skills': skills,
      'interests': interests,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'dreamCareer': dreamCareer,
      'industry': industry,
      'sectorPreference': sectorPreference,
    };
    
    final profileHash = SkillCacheManager.generateProfileHash(profileData);

    // 2. Check Cache
    final cachedReport = await SkillCacheManager.getCareerReport(profileHash);
    if (cachedReport != null && cachedReport.isNotEmpty) {
      return cachedReport;
    }

    // 3. Construct System Prompt
    const systemInstruction = """
You are an elite Career Mentor and Technical Guidance Coach.
Analyze the user's profile and generate a highly structured, comprehensive career report.
Your output must be written entirely in Markdown, using clean formatting, bullet points, headers, and emojis for readability.

CRITICAL INSTRUCTIONS:
- You must suggest both IT and Non-IT career options if applicable.
- Focus strictly on the user's sector preference (Government, Private, or Business/Freelance).
- Maintain a highly encouraging and professional tone.

Structure your response EXACTLY as follows:

# 🎯 Career Suitability Analysis

**Top Career Matches:**
- **[Career Title 1]** (Suitability: XX%): [1 sentence explaining why this matches them]
- **[Career Title 2]** (Suitability: XX%): [1 sentence explaining why this matches them]

---

# 💼 Market Scope & Overview

- **Salary Range:** [Expected entry to mid-level salary in their region or general]
- **Future Growth:** [Brief on industry trends]
- **Top Companies/Organizations Hiring:** [List 3-5 companies or Govt departments]

---

# 🛠️ Roles & Required Skills

- **Key Responsibilities:** [3-4 bullet points]
- **Must-Have Technical Skills:** [3-4 bullet points]
- **Essential Soft Skills:** [3-4 bullet points]
- **Recommended Certifications:** [2-3 certifications]

---

# 🚀 Execution Roadmap

### 📅 30-Day Goal: Foundation
- [Action item 1]
- [Action item 2]

### 📅 60-Day Goal: Intermediate
- [Action item 1]
- [Action item 2]

### 📅 90-Day Goal: Advanced & Apply
- [Action item 1]
- [Action item 2]

---

# 📝 Preparation Strategy

- **Interview Tips:** [2-3 specific tips]
- **Resume Improvements:** [2-3 specific tips]

---

# 📚 Free Learning Resources
- 📺 [YouTube Course / Playlist](https://www.youtube.com/results?search_query=...)
- 📖 [Documentation or Top Article](https://www.google.com/search?q=...)
- 💻 [Practice Platform](https://www.google.com/search?q=...)
""";

    // 4. Construct User Prompt
    final prompt = """
Please analyze my profile and provide my career report:
- Education: $education
- Skills: $skills
- Interests: $interests
- Strengths: $strengths
- Weaknesses: $weaknesses
- Dream Career: $dreamCareer
- Preferred Industry: $industry
- Sector Preference: $sectorPreference
""";

    // 5. Call AI
    debugPrint("CAREER_MENTOR [GENERATING AI REPORT]");
    try {
      // Use the helper method from GroqService (Note: GroqService._getGroqResponse is private, 
      // so we need to either make it public or add a public method. Let's assume we can add a generic call to GroqService).
      // Wait, let's look at GroqService. It doesn't have a public generic generateContent method.
      // I will need to update GroqService to expose a generic method.
      
      final response = await _groqService.generateGenericResponse(prompt, systemInstruction);
      
      if (!response.contains("AI Service Error:")) {
        // 6. Save to cache
        await SkillCacheManager.saveCareerReport(profileHash, response);
      }
      return response;
    } catch (e) {
      debugPrint("CAREER_MENTOR Error: $e");
      return "Error: Failed to generate career report. Please try again later.";
    }
  }
}
