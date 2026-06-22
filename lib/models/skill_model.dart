class SkillModel {
  final String name;
  final int level; // 0 - 100
  final bool isRecommended;

  SkillModel({
    required this.name,
    required this.level,
    this.isRecommended = false,
  });

  factory SkillModel.fromMap(Map<String, dynamic> map) {
    return SkillModel(
      name: map['name'],
      level: map['level'],
      isRecommended: map['isRecommended'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'level': level,
      'isRecommended': isRecommended,
    };
  }
}