class AnalysisModel {

  final int atsScore;

  final List<String> skills;

  final List<String> missingSkills;

  final List<String> suggestions;

  AnalysisModel({

    required this.atsScore,

    required this.skills,

    required this.missingSkills,

    required this.suggestions,
  });

  factory AnalysisModel.fromJson(
      Map<String, dynamic> json) {

    return AnalysisModel(

      atsScore:
          json["ats_score"],

      skills:
          List<String>.from(
        json["skills"],
      ),

      missingSkills:
          List<String>.from(
        json["missing_skills"],
      ),

      suggestions:
          List<String>.from(
        json["suggestions"],
      ),
    );
  }
}
