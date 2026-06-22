class JDAdvancedBooleanATS {
  // =====================================================
  // SKILL MASTER
  // =====================================================

  static final Map<String, List<String>> roleSkills = {
    "FRONTEND": [
      "html",
      "css",
      "javascript",
      "react",
      "flutter",
      "ui",
    ],
    "BACKEND": [
      "java",
      "spring",
      "spring boot",
      "node",
      "nodejs",
      "python",
      "rest api",
      "mysql",
      "sql",
    ],
    "FULLSTACK": [
      "frontend",
      "backend",
      "react",
      "node",
      "java",
      "api",
      "sql",
    ],
  };

  static final List<String> allSkills =
      roleSkills.values.expand((e) => e).toSet().toList();

  // =====================================================
  // NORMALIZE & WORD MATCH
  // =====================================================

  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  }

  static bool _wordMatch(String text, String skill) {
    final words = _normalize(text).split(RegExp(r'\s+'));
    return words.contains(skill);
  }

  // =====================================================
  // EXTRACT JD SKILLS
  // =====================================================

  static List<String> extractJDSkills(String jdText) {
    final normalized = _normalize(jdText);
    final List<String> found = [];

    for (final skill in allSkills) {
      if (_wordMatch(normalized, skill)) {
        found.add(skill.toUpperCase());
      }
    }
    return found;
  }

  // =====================================================
  // EXTRACT RESUME SKILLS
  // =====================================================

  static List<String> extractResumeSkills(String resumeText) {
    final normalized = _normalize(resumeText);
    final List<String> found = [];

    for (final skill in allSkills) {
      if (_wordMatch(normalized, skill)) {
        found.add(skill.toUpperCase());
      }
    }
    return found;
  }

  // =====================================================
  // ROLE DETECTION (JD BASED)
  // =====================================================

  static String detectRole(String jdText) {
    final jdSkills = extractJDSkills(jdText);
    int max = 0;
    String role = "GENERAL";

    roleSkills.forEach((key, skills) {
      int count = skills
          .map((e) => e.toUpperCase())
          .where((e) => jdSkills.contains(e))
          .length;

      if (count > max) {
        max = count;
        role = key;
      }
    });

    return role;
  }

  // =====================================================
  // ATS ANALYSIS
  // =====================================================

  static Map<String, dynamic> analyze({
    required String resumeText,
    required String jdText,
  }) {
    final jdSkills = extractJDSkills(jdText);
    final resumeSkills = extractResumeSkills(resumeText);

    final matched =
        jdSkills.where((s) => resumeSkills.contains(s)).toList();

    final missing =
        jdSkills.where((s) => !resumeSkills.contains(s)).toList();

    // ================= SCORE =================
    int score = jdSkills.isEmpty
        ? 0
        : ((matched.length / jdSkills.length) * 100).round();

    // ================= STRENGTH =================
    String strength;
    if (score >= 75) {
      strength = "Strong ATS Match";
    } else if (score >= 50) {
      strength = "Moderate Match";
    } else {
      strength = "Low Match";
    }

    // ================= ELIGIBLE ROLES (✅ FIX HERE) =================
    final String role = detectRole(jdText);
    List<String> eligibleRoles = [];

    if (score >= 70) {
      eligibleRoles.add("Eligible for $role Role");
    } else if (score >= 50) {
      eligibleRoles.add("Partially eligible for $role Role");
    } else {
      eligibleRoles.add("Not eligible for $role Role");
    }

    // ================= REJECTION REASONS =================
    List<String> rejectionReasons = [];
    if (score < 60) {
      rejectionReasons.add("JD required skills missing");
    }

    // ================= OPTIMIZATION =================
    List<String> tips = [];
    if (missing.isNotEmpty) {
      tips.add("Add missing JD skills: ${missing.join(", ")}");
    }
    tips.add("Use JD keywords exactly as written");
    tips.add("Mention skills in project descriptions");

    // ================= FINAL RESPONSE =================
    return {
      "detectedRole": role,
      "matchScore": score,
      "jdSkills": jdSkills,
      "matchedSkills": matched,
      "missingSkills": missing,
      "resumeStrength": strength,
      "eligibleRoles": eligibleRoles,
      "rejectionReasons": rejectionReasons,
      "resumeOptimizationTips": tips,
      "resumeSummary":
          "Resume analyzed using deterministic rule-based ATS (No AI).",
    };
  }
}
