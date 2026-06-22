import '/screens/data/skill_questions.dart';
import '../models/question_model.dart';
import '../models/result_model.dart';

class SkillEngine {
  List<QuestionModel> loadQuestions(String skill) {
    final key = skill.toLowerCase();

    if (!skillQuestions.containsKey(key)) {
      throw Exception("Skill not found");
    }

    return skillQuestions[key]!;
  }

  ResultModel calculateResult({
    required String skill,
    required List<QuestionModel> questions,
    required int correct,
  }) {
    final total = questions.length;

    final percentage =
        total == 0 ? 0.0 : (correct / total) * 100;

    return ResultModel(
      total: total,
      correct: correct,
      percentage: percentage,
      skillScores: _generateSkillScores(
        skill,
        percentage,
      ),
    );
  }

  Map<String, double> _generateSkillScores(
    String skill,
    double score,
  ) {
    switch (skill.toLowerCase()) {
      case "flutter":
        return {
          "UI Development":
              (score + 20).clamp(0, 100),
          "State Management":
              (score - 10).clamp(0, 100),
          "Firebase":
              (score - 20).clamp(0, 100),
          "API Integration":
              score.clamp(0, 100),
          "Architecture":
              (score - 25).clamp(0, 100),
        };

      case "react":
        return {
          "Components":
              (score + 15).clamp(0, 100),
          "Hooks":
              score.clamp(0, 100),
          "Redux":
              (score - 20).clamp(0, 100),
          "Routing":
              (score + 5).clamp(0, 100),
          "Performance":
              (score - 15).clamp(0, 100),
        };

      case "python":
        return {
          "Syntax":
              (score + 20).clamp(0, 100),
          "OOP":
              score.clamp(0, 100),
          "Libraries":
              (score - 10).clamp(0, 100),
          "APIs":
              (score - 15).clamp(0, 100),
          "Problem Solving":
              (score + 10).clamp(0, 100),
        };

      case "java":
        return {
          "Core Java":
              (score + 15).clamp(0, 100),
          "Collections":
              score.clamp(0, 100),
          "OOP":
              (score + 10).clamp(0, 100),
          "Spring Boot":
              (score - 20).clamp(0, 100),
          "JDBC":
              (score - 10).clamp(0, 100),
        };

      case "web development":
        return {
          "HTML":
              (score + 20).clamp(0, 100),
          "CSS":
              (score + 10).clamp(0, 100),
          "JavaScript":
              score.clamp(0, 100),
          "Responsive":
              (score - 5).clamp(0, 100),
          "Backend":
              (score - 20).clamp(0, 100),
        };

      default:
        return {
          "Knowledge":
              score.clamp(0, 100),
          "Projects":
              (score - 5).clamp(0, 100),
          "Debugging":
              (score - 10).clamp(0, 100),
          "Problem Solving":
              (score + 5).clamp(0, 100),
          "Advanced Concepts":
              (score - 15).clamp(0, 100),
        };
    }
  }
}