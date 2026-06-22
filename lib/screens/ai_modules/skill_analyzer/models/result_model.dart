class ResultModel {
  final int total;
  final int correct;
  final double percentage;

  /// Dynamic skill scores
  final Map<String, double> skillScores;

  const ResultModel({
    required this.total,
    required this.correct,
    required this.percentage,
    required this.skillScores,
  });

  factory ResultModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResultModel(
      total: json["total"] ?? 0,
      correct: json["correct"] ?? 0,
      percentage:
          (json["percentage"] ?? 0)
              .toDouble(),

      skillScores: Map<String, double>.from(
        (json["skillScores"] ?? {})
            .map(
          (key, value) => MapEntry(
            key.toString(),
            (value as num).toDouble(),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "total": total,
      "correct": correct,
      "percentage": percentage,
      "skillScores": skillScores,
    };
  }

  ResultModel copyWith({
    int? total,
    int? correct,
    double? percentage,
    Map<String, double>? skillScores,
  }) {
    return ResultModel(
      total: total ?? this.total,
      correct: correct ?? this.correct,
      percentage:
          percentage ?? this.percentage,
      skillScores:
          skillScores ?? this.skillScores,
    );
  }

  /// Highest skill
  String get strongestSkill {
    if (skillScores.isEmpty) {
      return "N/A";
    }

    return skillScores.entries
        .reduce(
          (a, b) =>
              a.value > b.value
                  ? a
                  : b,
        )
        .key;
  }

  /// Weakest skill
  String get weakestSkill {
    if (skillScores.isEmpty) {
      return "N/A";
    }

    return skillScores.entries
        .reduce(
          (a, b) =>
              a.value < b.value
                  ? a
                  : b,
        )
        .key;
  }

  /// Average score
  double get averageScore {
    if (skillScores.isEmpty) {
      return 0;
    }

    return skillScores.values.reduce(
          (a, b) => a + b,
        ) /
        skillScores.length;
  }

  @override
  String toString() {
    return '''
 ResultModel(
  total: $total,
  correct: $correct,
  percentage: $percentage,
  strongestSkill: $strongestSkill,
  weakestSkill: $weakestSkill,
  averageScore: $averageScore,
  skillScores: $skillScores
)
''';
  }
}
