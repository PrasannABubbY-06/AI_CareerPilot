import 'package:flutter/material.dart';

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int xpReward;
  final Color color;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.color,
  });

  static List<AchievementModel> get allAchievements => [
    const AchievementModel(
      id: "first_roadmap",
      title: "First Steps",
      description: "Created your very first learning roadmap.",
      icon: Icons.map_rounded,
      xpReward: 50,
      color: Colors.blueAccent,
    ),
    const AchievementModel(
      id: "first_task",
      title: "Initiator",
      description: "Completed your first roadmap task.",
      icon: Icons.check_circle_rounded,
      xpReward: 20,
      color: Colors.greenAccent,
    ),
    const AchievementModel(
      id: "streak_7",
      title: "Consistent Learner",
      description: "Maintained a 7-day learning streak.",
      icon: Icons.local_fire_department_rounded,
      xpReward: 150,
      color: Colors.orangeAccent,
    ),
    const AchievementModel(
      id: "streak_30",
      title: "Unstoppable Force",
      description: "Maintained a 30-day learning streak.",
      icon: Icons.whatshot_rounded,
      xpReward: 500,
      color: Colors.redAccent,
    ),
    const AchievementModel(
      id: "resume_master",
      title: "Resume Master",
      description: "Used the AI Resume Reviewer.",
      icon: Icons.document_scanner_rounded,
      xpReward: 100,
      color: Colors.purpleAccent,
    ),
    const AchievementModel(
      id: "interview_champ",
      title: "Interview Champion",
      description: "Completed your first mock interview.",
      icon: Icons.mic_rounded,
      xpReward: 200,
      color: Colors.tealAccent,
    ),
    const AchievementModel(
      id: "skill_collector",
      title: "Skill Collector",
      description: "Completed 10 roadmap tasks.",
      icon: Icons.auto_awesome_rounded,
      xpReward: 300,
      color: Colors.amber,
    ),
    const AchievementModel(
      id: "job_ready",
      title: "Job Ready",
      description: "Reached level 75 or completed 80% of a roadmap.",
      icon: Icons.work_rounded,
      xpReward: 1000,
      color: Colors.indigoAccent,
    ),
  ];
}
