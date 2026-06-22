class SkillAnalyzerState {

  String skill;

  String goal;

  String experience;

  Map<String, int> ratings;

  SkillAnalyzerState({
    required this.skill,
    required this.goal,
    required this.experience,
    required this.ratings,
  });

  factory SkillAnalyzerState.empty() {
    return SkillAnalyzerState(
      skill: "",
      goal: "",
      experience: "",
      ratings: {},
    );
  }
}