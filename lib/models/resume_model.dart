class ResumeModel {
  final double atsScore;
  final int grammarScore;
  final List<String> missingKeywords;
  final List<String> suggestions;

  ResumeModel({
    required this.atsScore,
    required this.grammarScore,
    required this.missingKeywords,
    required this.suggestions,
  });

  factory ResumeModel.fromMap(Map<String, dynamic> map) {
    return ResumeModel(
      atsScore: (map['atsScore'] as num).toDouble(),
      grammarScore: map['grammarScore'],
      missingKeywords: List<String>.from(map['missingKeywords']),
      suggestions: List<String>.from(map['suggestions']),
    );
  }
}