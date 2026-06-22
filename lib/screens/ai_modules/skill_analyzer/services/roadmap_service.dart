import '../models/roadmap_model.dart';

class RoadmapService {
  static List<String> getStrengths(
    Map<String, double> scores,
  ) {
    List<String> strengths = [];

    scores.forEach((skill, score) {
      if (score >= 70) {
        strengths.add(skill);
      }
    });

    return strengths;
  }

  static List<String> getGaps(
    Map<String, double> scores,
  ) {
    List<String> gaps = [];

    scores.forEach((skill, score) {
      if (score < 60) {
        gaps.add(skill);
      }
    });

    return gaps;
  }

  static String getLevel(
    double percentage,
  ) {
    if (percentage >= 80) {
      return "Advanced";
    }

    if (percentage >= 50) {
      return "Intermediate";
    }

    return "Beginner";
  }

  static List<RoadmapModel> generateRoadmap(
    Map<String, double> scores,
  ) {
    List<RoadmapModel> roadmap = [];

    scores.forEach((skill, score) {
      if (score < 40) {
        roadmap.add(
          RoadmapModel(
            module: skill,
            description:
                "Focus heavily on mastering $skill from fundamentals to project level.",
            hours: 8,
            priority: "High",
          ),
        );
      } else if (score < 60) {
        roadmap.add(
          RoadmapModel(
            module: skill,
            description:
                "Improve your understanding of $skill through guided practice and projects.",
            hours: 5,
            priority: "Medium",
          ),
        );
      } else if (score < 75) {
        roadmap.add(
          RoadmapModel(
            module: skill,
            description:
                "Strengthen your existing knowledge in $skill with advanced concepts.",
            hours: 3,
            priority: "Low",
          ),
        );
      }
    });

    roadmap.sort((a, b) {
      final priorityOrder = {
        "High": 1,
        "Medium": 2,
        "Low": 3,
      };

      return priorityOrder[a.priority]!
          .compareTo(
        priorityOrder[b.priority]!,
      );
    });

    return roadmap;
  }

  static int calculateHours(
    List<RoadmapModel> roadmap,
  ) {
    int total = 0;

    for (final item in roadmap) {
      total += item.hours;
    }

    return total;
  }

  static double getReadinessScore(
    Map<String, double> scores,
  ) {
    if (scores.isEmpty) return 0;

    double total = 0;

    for (final value in scores.values) {
      total += value;
    }

    return total / scores.length;
  }

  static String nextFocusArea(
    Map<String, double> scores,
  ) {
    if (scores.isEmpty) {
      return "Start Learning";
    }

    String weakestSkill = "";
    double lowestScore = 100;

    scores.forEach((skill, score) {
      if (score < lowestScore) {
        lowestScore = score;
        weakestSkill = skill;
      }
    });

    return weakestSkill;
  }
}
