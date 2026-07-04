class CareerQuizScoringEngine {
  // Domain score indices
  static const String IT = "IT";
  static const String NON_IT = "Non-IT";
  static const String BUSINESS = "Business";
  static const String GOV = "Government";

  // Deterministic local scoring logic
  static Map<String, double> calculateScores(Map<String, String> answers) {
    Map<String, double> scores = {
      IT: 0.0,
      NON_IT: 0.0,
      BUSINESS: 0.0,
      GOV: 0.0,
    };

    // Analyze each answer and assign points to domains
    answers.forEach((question, answer) {
      // 1. Interest Type
      if (answer.contains("Building things and writing code") || answer.contains("hardware")) {
        scores[IT] = scores[IT]! + 3;
      } else if (answer.contains("Managing projects") || answer.contains("how it makes money")) {
        scores[BUSINESS] = scores[BUSINESS]! + 3;
      } else if (answer.contains("Social") || answer.contains("helping") || answer.contains("clients")) {
        scores[NON_IT] = scores[NON_IT]! + 2;
        scores[GOV] = scores[GOV]! + 1;
      } else if (answer.contains("Designing visuals") || answer.contains("Arts")) {
        scores[NON_IT] = scores[NON_IT]! + 3;
      }

      // 2. Personality Type
      if (answer.contains("Independently, deep focused work")) {
        scores[IT] = scores[IT]! + 2;
      } else if (answer.contains("large group with lots of collaboration")) {
        scores[BUSINESS] = scores[BUSINESS]! + 2;
        scores[NON_IT] = scores[NON_IT]! + 1;
      } else if (answer.contains("Directly interacting with clients or customers")) {
        scores[BUSINESS] = scores[BUSINESS]! + 2;
        scores[NON_IT] = scores[NON_IT]! + 2;
      }

      // 3. Work Style & Stress
      if (answer.contains("stable corporate environments") || answer.contains("secure public sector")) {
        scores[GOV] = scores[GOV]! + 4;
      } else if (answer.contains("high-risk, high-reward startups") || answer.contains("running my own company")) {
        scores[BUSINESS] = scores[BUSINESS]! + 4;
        scores[IT] = scores[IT]! + 1;
      }

      // 4. Problem Solving & Logic
      if (answer.contains("Break it down into smaller, logical steps") || answer.contains("Excitement to hunt down the root cause")) {
        scores[IT] = scores[IT]! + 3;
        scores[GOV] = scores[GOV]! + 1; // methodical
      } else if (answer.contains("Collaborate and brainstorm")) {
        scores[BUSINESS] = scores[BUSINESS]! + 2;
        scores[NON_IT] = scores[NON_IT]! + 2;
      }

      // 5. Data & Spreadsheets
      if (answer.contains("I love it, data tells a story")) {
        scores[BUSINESS] = scores[BUSINESS]! + 2;
        scores[IT] = scores[IT]! + 2; // Data science/analyst
      } else if (answer.contains("qualitative research over numbers")) {
        scores[NON_IT] = scores[NON_IT]! + 2;
      }

      // 6. Education
      if (answer.contains("Computer Science / IT")) {
        scores[IT] = scores[IT]! + 4;
      } else if (answer.contains("Business / Management")) {
        scores[BUSINESS] = scores[BUSINESS]! + 4;
      } else if (answer.contains("Arts / Design")) {
        scores[NON_IT] = scores[NON_IT]! + 4;
      } else if (answer.contains("Science / Mathematics")) {
        scores[IT] = scores[IT]! + 2;
        scores[GOV] = scores[GOV]! + 2; // Research/Gov jobs
      }
    });

    return scores;
  }

  static String getTopDomain(Map<String, double> scores) {
    String top = IT;
    double maxScore = -1;
    scores.forEach((key, value) {
      if (value > maxScore) {
        maxScore = value;
        top = key;
      }
    });
    return top;
  }

  static String getSecondaryDomain(Map<String, double> scores, String topDomain) {
    String sec = NON_IT;
    double maxScore = -1;
    scores.forEach((key, value) {
      if (key != topDomain && value > maxScore) {
        maxScore = value;
        sec = key;
      }
    });
    return sec;
  }
}
