import 'dart:convert';

class CareerQuizResultModel {
  final String answersHash;
  final String primaryDomain;
  final String secondaryDomain;
  final int suitabilityPercentage;
  final Map<String, dynamic> domainScores;
  
  // AI Generated Content
  final List<String> recommendedRoles;
  final List<String> strengths;
  final List<String> weaknesses;
  final String explanation;
  final List<String> learningRoadmap;
  final String nextSkill;
  
  final DateTime timestamp;

  const CareerQuizResultModel({
    required this.answersHash,
    required this.primaryDomain,
    required this.secondaryDomain,
    required this.suitabilityPercentage,
    required this.domainScores,
    required this.recommendedRoles,
    required this.strengths,
    required this.weaknesses,
    required this.explanation,
    required this.learningRoadmap,
    required this.nextSkill,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'answersHash': answersHash,
      'primaryDomain': primaryDomain,
      'secondaryDomain': secondaryDomain,
      'suitabilityPercentage': suitabilityPercentage,
      'domainScores': domainScores,
      'recommendedRoles': recommendedRoles,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'explanation': explanation,
      'learningRoadmap': learningRoadmap,
      'nextSkill': nextSkill,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory CareerQuizResultModel.fromMap(Map<String, dynamic> map) {
    return CareerQuizResultModel(
      answersHash: map['answersHash'] ?? '',
      primaryDomain: map['primaryDomain'] ?? '',
      secondaryDomain: map['secondaryDomain'] ?? '',
      suitabilityPercentage: map['suitabilityPercentage']?.toInt() ?? 0,
      domainScores: Map<String, dynamic>.from(map['domainScores'] ?? {}),
      recommendedRoles: List<String>.from(map['recommendedRoles'] ?? []),
      strengths: List<String>.from(map['strengths'] ?? []),
      weaknesses: List<String>.from(map['weaknesses'] ?? []),
      explanation: map['explanation'] ?? '',
      learningRoadmap: List<String>.from(map['learningRoadmap'] ?? []),
      nextSkill: map['nextSkill'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory CareerQuizResultModel.fromJson(String source) => CareerQuizResultModel.fromMap(json.decode(source));
}
