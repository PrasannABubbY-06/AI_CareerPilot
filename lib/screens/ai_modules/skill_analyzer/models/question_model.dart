class QuestionModel {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String level;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.level,
  });

  // ================= FROM JSON =================
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json["question"]?.toString() ?? "",
      options: json["options"] != null
          ? List<String>.from(json["options"])
          : [],
      correctIndex: json["correctIndex"] ??
          json["answer"] ??
          0,
      level: json["level"]?.toString() ?? "beginner",
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      "question": question,
      "options": options,
      "correctIndex": correctIndex,
      "level": level,
    };
  }

  // ================= HELPERS =================
  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctIndex;
  }

  bool get isBeginner => level == "beginner";
  bool get isIntermediate => level == "intermediate";
  bool get isAdvanced => level == "advanced";

  @override
  String toString() {
    return "QuestionModel(level: $level, question: $question)";
  }
}



