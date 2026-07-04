import 'dart:convert';

class SkillJourneyModel {
  final String skillName;
  final int currentLevelIndex; // 0=Beginner, 1=Intermediate, 2=Advanced, 3=Expert, 4=JobReady
  final double progressPercentage;
  final DateTime lastActiveDate;
  final String status; // active, completed

  const SkillJourneyModel({
    required this.skillName,
    this.currentLevelIndex = 0,
    this.progressPercentage = 0.0,
    required this.lastActiveDate,
    this.status = "active",
  });

  SkillJourneyModel copyWith({
    String? skillName,
    int? currentLevelIndex,
    double? progressPercentage,
    DateTime? lastActiveDate,
    String? status,
  }) {
    return SkillJourneyModel(
      skillName: skillName ?? this.skillName,
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'skillName': skillName,
      'currentLevelIndex': currentLevelIndex,
      'progressPercentage': progressPercentage,
      'lastActiveDate': lastActiveDate.millisecondsSinceEpoch,
      'status': status,
    };
  }

  factory SkillJourneyModel.fromMap(Map<String, dynamic> map) {
    return SkillJourneyModel(
      skillName: map['skillName'] ?? '',
      currentLevelIndex: map['currentLevelIndex']?.toInt() ?? 0,
      progressPercentage: map['progressPercentage']?.toDouble() ?? 0.0,
      lastActiveDate: DateTime.fromMillisecondsSinceEpoch(map['lastActiveDate'] ?? DateTime.now().millisecondsSinceEpoch),
      status: map['status'] ?? 'active',
    );
  }

  String toJson() => json.encode(toMap());

  factory SkillJourneyModel.fromJson(String source) => SkillJourneyModel.fromMap(json.decode(source));
}

class JourneyHistoryModel {
  final String skillName;
  final int finalLevelIndex;
  final double completionPercentage;
  final DateTime startDate;
  final DateTime endDate;

  const JourneyHistoryModel({
    required this.skillName,
    required this.finalLevelIndex,
    required this.completionPercentage,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'skillName': skillName,
      'finalLevelIndex': finalLevelIndex,
      'completionPercentage': completionPercentage,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
    };
  }

  factory JourneyHistoryModel.fromMap(Map<String, dynamic> map) {
    return JourneyHistoryModel(
      skillName: map['skillName'] ?? '',
      finalLevelIndex: map['finalLevelIndex']?.toInt() ?? 0,
      completionPercentage: map['completionPercentage']?.toDouble() ?? 0.0,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] ?? DateTime.now().millisecondsSinceEpoch),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }
}
