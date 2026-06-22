class InterviewModel {
  final int confidenceScore;
  final int communicationScore;
  final int technicalScore;
  final List<String> feedback;

  InterviewModel({
    required this.confidenceScore,
    required this.communicationScore,
    required this.technicalScore,
    required this.feedback,
  });

  factory InterviewModel.fromMap(Map<String, dynamic> map) {
    return InterviewModel(
      confidenceScore: map['confidenceScore'],
      communicationScore: map['communicationScore'],
      technicalScore: map['technicalScore'],
      feedback: List<String>.from(map['feedback']),
    );
  }
}
