// jd_boolean_service.dart
// Pure Boolean ATS JD Matcher (NO AI)

class JDBooleanService {
  // =====================================================
  // MASTER SKILL DICTIONARY (EXTENDABLE)
  // =====================================================

  static final Map<String, List<String>> skillMap = {
    "FLUTTER": ["flutter"],
    "DART": ["dart"],
    "FIREBASE": ["firebase"],
    "JAVA": ["java"],
    "SPRING": ["spring", "spring boot"],
    "PYTHON": ["python"],
    "REACT": ["react", "reactjs"],
    "NODE": ["node", "nodejs"],
    "MYSQL": ["mysql"],
    "SQL": ["sql"],
    "REST API": ["api", "rest", "rest api"],
    "GIT": ["git", "github"],
    "DOCKER": ["docker"],
    "AWS": ["aws", "amazon web services"],
  };

  // =====================================================
  // EXCLUDED WORDS (BOOLEAN NOT)
  // =====================================================

  static final List<String> excludedKeywords = [
    "fresher",
    "intern",
    "trainee",
  ];

  // =====================================================
  // TEXT NORMALIZATION
  // =====================================================

  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  }

  // =====================================================
  // SKILL EXTRACTION
  // =====================================================

  static List<String> extractSkills(String text) {
    final normalized = normalize(text);
    final List<String> found = [];

    skillMap.forEach((skill, keywords) {
      for (final k in keywords) {
        if (normalized.contains(k)) {
          found.add(skill);
          break;
        }
      }
    });

    return found;
  }

  // =====================================================
  // BOOLEAN JD ANALYSIS (CORE LOGIC)
  // =====================================================

  static Map<String, dynamic> analyze({
    required String resumeText,
    required String jdText,
  }) {
    final resumeSkills = extractSkills(resumeText);
    final jdSkills = extractSkills(jdText);

    final matchedSkills = <String>[];
    final missingSkills = <String>[];

    // ---------- AND LOGIC ----------
    for (final skill in jdSkills) {
      if (resumeSkills.contains(skill)) {
        matchedSkills.add(skill);
      } else {
        missingSkills.add(skill);
      }
    }

    // ---------- NOT LOGIC ----------
    bool excluded = false;
    final resumeLower = normalize(resumeText);

    for (final word in excludedKeywords) {
      if (resumeLower.contains(word)) {
        excluded = true;
        break;
      }
    }

    // ---------- SCORE CALCULATION ----------
    int matchScore = 0;

    if (jdSkills.isNotEmpty) {
      matchScore =
          ((matchedSkills.length / jdSkills.length) * 100).round();
    }

    if (excluded) {
      matchScore = (matchScore * 0.5).round();
    }

    // ---------- STRENGTH MESSAGE ----------
    String resumeStrength;
    if (matchScore >= 75) {
      resumeStrength = "Strong ATS match for the role";
    } else if (matchScore >= 50) {
      resumeStrength = "Moderate match – improvement recommended";
    } else {
      resumeStrength = "Low match – skill gaps identified";
    }

    // ---------- ELIGIBLE ROLES ----------
    List<String> eligibleRoles = [];
    if (matchScore >= 50 && !excluded) {
      eligibleRoles.add("JD Matched Role");
    }

    // ---------- SUGGESTIONS ----------
    List<String> suggestions = [];
    if (missingSkills.isNotEmpty) {
      suggestions.add(
        "Improve skills: ${missingSkills.join(", ")}",
      );
    } else {
      suggestions.add("Resume aligns well with JD requirements");
    }

    if (excluded) {
      suggestions.add("Profile contains excluded keywords (Fresher/Intern)");
    }

    // =====================================================
    // FINAL RESPONSE
    // =====================================================

    return {
      "matchScore": matchScore,
      "requiredSkills": jdSkills,
      "matchedSkills": matchedSkills,
      "missingSkills": missingSkills,
      "resumeStrength": resumeStrength,
      "eligibleRoles": eligibleRoles,
      "suggestions": suggestions,
      "resumeSummary":
          "Resume evaluated using rule-based Boolean ATS logic without AI.",
    };
  }
}
