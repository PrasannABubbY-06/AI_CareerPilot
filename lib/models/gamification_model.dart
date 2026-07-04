import 'dart:convert';

class GamificationModel {
  final int xp;
  final int level;
  final int coins;
  final int streakDays;
  final DateTime? lastActiveDate;
  final List<String> completedTasks;
  final List<String> achievements;
  final String? activeRoadmapSkill;

  final int todayXp;
  final int yesterdayXp;
  final List<String> todayTasks;
  final List<String> yesterdayTasks;

  final String? careerGoal;
  final String? targetRole;

  GamificationModel({
    this.xp = 0,
    this.level = 1,
    this.coins = 0,
    this.streakDays = 0,
    this.lastActiveDate,
    this.completedTasks = const [],
    this.achievements = const [],
    this.activeRoadmapSkill,
    this.todayXp = 0,
    this.yesterdayXp = 0,
    this.todayTasks = const [],
    this.yesterdayTasks = const [],
    this.careerGoal,
    this.targetRole,
  });

  GamificationModel copyWith({
    int? xp,
    int? level,
    int? coins,
    int? streakDays,
    DateTime? lastActiveDate,
    List<String>? completedTasks,
    List<String>? achievements,
    String? activeRoadmapSkill,
    int? todayXp,
    int? yesterdayXp,
    List<String>? todayTasks,
    List<String>? yesterdayTasks,
    String? careerGoal,
    String? targetRole,
  }) {
    return GamificationModel(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      coins: coins ?? this.coins,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      completedTasks: completedTasks ?? this.completedTasks,
      achievements: achievements ?? this.achievements,
      activeRoadmapSkill: activeRoadmapSkill ?? this.activeRoadmapSkill,
      todayXp: todayXp ?? this.todayXp,
      yesterdayXp: yesterdayXp ?? this.yesterdayXp,
      todayTasks: todayTasks ?? this.todayTasks,
      yesterdayTasks: yesterdayTasks ?? this.yesterdayTasks,
      careerGoal: careerGoal ?? this.careerGoal,
      targetRole: targetRole ?? this.targetRole,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'xp': xp,
      'level': level,
      'coins': coins,
      'streakDays': streakDays,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'completedTasks': completedTasks,
      'achievements': achievements,
      'activeRoadmapSkill': activeRoadmapSkill,
      'todayXp': todayXp,
      'yesterdayXp': yesterdayXp,
      'todayTasks': todayTasks,
      'yesterdayTasks': yesterdayTasks,
      'careerGoal': careerGoal,
      'targetRole': targetRole,
    };
  }

  factory GamificationModel.fromMap(Map<String, dynamic> map) {
    return GamificationModel(
      xp: map['xp']?.toInt() ?? 0,
      level: map['level']?.toInt() ?? 1,
      coins: map['coins']?.toInt() ?? 0,
      streakDays: map['streakDays']?.toInt() ?? 0,
      lastActiveDate: map['lastActiveDate'] != null ? DateTime.parse(map['lastActiveDate']) : null,
      completedTasks: List<String>.from(map['completedTasks'] ?? []),
      achievements: List<String>.from(map['achievements'] ?? []),
      activeRoadmapSkill: map['activeRoadmapSkill'],
      todayXp: map['todayXp']?.toInt() ?? 0,
      yesterdayXp: map['yesterdayXp']?.toInt() ?? 0,
      todayTasks: List<String>.from(map['todayTasks'] ?? []),
      yesterdayTasks: List<String>.from(map['yesterdayTasks'] ?? []),
      careerGoal: map['careerGoal'],
      targetRole: map['targetRole'],
    );
  }

  String toJson() => json.encode(toMap());

  factory GamificationModel.fromJson(String source) => GamificationModel.fromMap(json.decode(source));
}
