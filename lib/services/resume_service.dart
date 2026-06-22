class ResumeService {
  // ================= ALL SKILLS DATABASE =================

  final List<String> allSkills = [
    "flutter",
    "dart",
    "firebase",
    "rest api",
    "api",
    "git",
    "github",
    "java",
    "python",
    "c",
    "c++",
    "sql",
    "mysql",
    "postgresql",
    "mongodb",
    "html",
    "css",
    "javascript",
    "typescript",
    "react",
    "next.js",
    "node.js",
    "express",
    "spring",
    "spring boot",
    "android",
    "kotlin",
    "swift",
    "ui",
    "ux",
    "figma",
    "json",
    "problem solving",
    "communication",
    "leadership",
    "teamwork",
    "data structures",
    "algorithms",
    "oops",
    "machine learning",
    "deep learning",
    "artificial intelligence",
    "data analysis",
    "power bi",
    "excel",
    "aws",
    "docker",
    "kubernetes",
    "linux",
    "testing",
  ];

  // ================= ROLE BASED SKILLS =================

  final Map<String, List<String>> roleSkills = {
    "Flutter Developer": [
      "flutter",
      "dart",
      "firebase",
      "rest api",
      "git",
      "ui",
    ],
    "Frontend Developer": [
      "html",
      "css",
      "javascript",
      "react",
      "ui",
      "ux",
    ],
    "Backend Developer": [
      "java",
      "sql",
      "api",
      "oops",
      "spring boot",
    ],
    "Full Stack Developer": [
      "html",
      "css",
      "javascript",
      "react",
      "node.js",
      "sql",
    ],
    "Android Developer": [
      "java",
      "kotlin",
      "android",
      "api",
    ],
    "Data Analyst": [
      "sql",
      "excel",
      "power bi",
      "data analysis",
    ],
    "Machine Learning Engineer": [
      "python",
      "machine learning",
      "data analysis",
      "algorithms",
    ],
    "DevOps Engineer": [
      "aws",
      "docker",
      "kubernetes",
      "linux",
      "git",
    ],
  };

  // ================= DETECT SKILLS =================

  List<String> detectSkills(String resumeText) {
    final text = resumeText.toLowerCase();

    final detected = <String>{};

    for (final skill in allSkills) {
      if (text.contains(skill.toLowerCase())) {
        detected.add(skill);
      }
    }

    return detected.toList()..sort();
  }

  // ================= FIND BEST ROLE =================

  String detectBestRole(List<String> detectedSkills) {
    String bestRole = "Software Trainee";
    double bestMatch = 0;

    roleSkills.forEach((role, skills) {
      int matched =
          skills.where((skill) => detectedSkills.contains(skill)).length;

      double percentage = matched / skills.length;

      if (percentage > bestMatch) {
        bestMatch = percentage;
        bestRole = role;
      }
    });

    return bestRole;
  }

  // ================= REQUIRED SKILLS =================

  List<String> requiredSkillsForRole(String role) {
    return roleSkills[role] ?? [];
  }

  // ================= MISSING SKILLS =================

  List<String> findMissingSkills(
    List<String> detected,
    List<String> required,
  ) {
    return required.where((skill) => !detected.contains(skill)).toList();
  }

  // ================= ATS SCORE =================

  int calculateATSScore(
    List<String> detected,
    List<String> required,
  ) {
    if (required.isEmpty) return 0;

    int matched =
        required.where((skill) => detected.contains(skill)).length;

    double roleScore = (matched / required.length) * 100;

    int bonus = 0;

    if (detected.length >= 5) bonus += 5;
    if (detected.length >= 10) bonus += 5;
    if (detected.length >= 15) bonus += 5;

    int finalScore = (roleScore + bonus).round();

    if (finalScore > 100) {
      finalScore = 100;
    }

    return finalScore;
  }

  // ================= JOB RECOMMENDATIONS =================

  List<String> recommendJobs(
    String bestRole,
    int atsScore,
  ) {
    if (atsScore >= 80) {
      return [
        bestRole,
        "Software Engineer",
        "Application Developer",
        "Associate Developer",
      ];
    }

    if (atsScore >= 60) {
      return [
        bestRole,
        "Junior $bestRole",
        "Trainee Developer",
        "Intern",
      ];
    }

    return [
      "Software Trainee",
      "Intern",
      "Graduate Engineer Trainee",
      "Entry Level Developer",
    ];
  }

  // ================= LEARNING PATH =================

  List<String> generateLearningPath(
    List<String> missingSkills,
  ) {
    final List<String> learningPath = [];

    for (final skill in missingSkills) {
      switch (skill.toLowerCase()) {
        case "flutter":
          learningPath.add(
            "Learn Flutter widgets, state management, navigation and deployment.",
          );
          break;

        case "dart":
          learningPath.add(
            "Master Dart fundamentals, OOP and asynchronous programming.",
          );
          break;

        case "firebase":
          learningPath.add(
            "Learn Firebase Authentication, Firestore and Storage.",
          );
          break;

        case "rest api":
        case "api":
          learningPath.add(
            "Learn REST APIs, HTTP methods and API integration.",
          );
          break;

        case "git":
        case "github":
          learningPath.add(
            "Learn version control, branching and GitHub collaboration.",
          );
          break;

        case "html":
          learningPath.add(
            "Learn semantic HTML and responsive layouts.",
          );
          break;

        case "css":
          learningPath.add(
            "Master Flexbox, Grid and responsive design.",
          );
          break;

        case "javascript":
          learningPath.add(
            "Learn ES6+, DOM manipulation and asynchronous JavaScript.",
          );
          break;

        case "react":
          learningPath.add(
            "Learn React components, hooks and state management.",
          );
          break;

        case "node.js":
          learningPath.add(
            "Learn backend development using Node.js and Express.",
          );
          break;

        case "java":
          learningPath.add(
            "Master Java fundamentals and backend development.",
          );
          break;

        case "python":
          learningPath.add(
            "Learn Python programming and automation.",
          );
          break;

        case "sql":
          learningPath.add(
            "Learn SQL queries, joins and database design.",
          );
          break;

        case "spring":
        case "spring boot":
          learningPath.add(
            "Build enterprise backend applications with Spring Boot.",
          );
          break;

        case "android":
          learningPath.add(
            "Learn Android app development fundamentals.",
          );
          break;

        case "kotlin":
          learningPath.add(
            "Master Kotlin for Android development.",
          );
          break;

        case "machine learning":
          learningPath.add(
            "Learn machine learning algorithms and model training.",
          );
          break;

        case "deep learning":
          learningPath.add(
            "Learn neural networks and deep learning frameworks.",
          );
          break;

        case "aws":
          learningPath.add(
            "Learn cloud deployment using AWS services.",
          );
          break;

        case "docker":
          learningPath.add(
            "Learn Docker containerization and deployment.",
          );
          break;

        case "kubernetes":
          learningPath.add(
            "Learn container orchestration using Kubernetes.",
          );
          break;

        case "linux":
          learningPath.add(
            "Learn Linux commands and server administration.",
          );
          break;

        case "data structures":
          learningPath.add(
            "Learn arrays, linked lists, trees and graphs.",
          );
          break;

        case "algorithms":
          learningPath.add(
            "Practice sorting, searching and optimization algorithms.",
          );
          break;

        case "oops":
          learningPath.add(
            "Master Object-Oriented Programming principles.",
          );
          break;

        default:
          learningPath.add(
            "Improve your knowledge and hands-on experience in $skill.",
          );
      }
    }

    return learningPath;
  }

  // ================= RESUME SUGGESTIONS =================

  List<String> generateResumeSuggestions(
    int atsScore,
    List<String> missingSkills,
  ) {
    List<String> suggestions = [];

    if (atsScore < 50) {
      suggestions.add(
        "Add more technical skills relevant to your target role.",
      );

      suggestions.add(
        "Include projects demonstrating practical experience.",
      );
    }

    if (atsScore < 70) {
      suggestions.add(
        "Improve ATS keyword matching with industry-relevant skills.",
      );
    }

    if (missingSkills.isNotEmpty) {
      suggestions.add(
        "Add or learn missing skills: ${missingSkills.join(', ')}.",
      );
    }

    suggestions.add(
      "Quantify achievements using measurable results.",
    );

    suggestions.add(
      "Add GitHub, LinkedIn and Portfolio links.",
    );

    suggestions.add(
      "Keep resume formatting ATS-friendly.",
    );

    suggestions.add(
      "Highlight certifications, internships and projects.",
    );

    return suggestions;
  }

  // ================= COMPLETE ANALYSIS =================

  Map<String, dynamic> analyzeResume(
    String resumeText,
  ) {
    final detectedSkills = detectSkills(resumeText);

    final bestRole = detectBestRole(
      detectedSkills,
    );

    final requiredSkills = requiredSkillsForRole(
      bestRole,
    );

    final missingSkills = findMissingSkills(
      detectedSkills,
      requiredSkills,
    );

    final atsScore = calculateATSScore(
      detectedSkills,
      requiredSkills,
    );

    final recommendedJobs = recommendJobs(
      bestRole,
      atsScore,
    );

    final learningPath = generateLearningPath(
      missingSkills,
    );

    final resumeSuggestions = generateResumeSuggestions(
      atsScore,
      missingSkills,
    );

    return {
      "detectedSkills": detectedSkills,
      "bestRole": bestRole,
      "requiredSkills": requiredSkills,
      "missingSkills": missingSkills,
      "atsScore": atsScore,
      "recommendedJobs": recommendedJobs,
      "learningPath": learningPath,
      "resumeSuggestions": resumeSuggestions,
    };
  }
}


