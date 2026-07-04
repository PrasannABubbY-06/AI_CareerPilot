import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/gamification_service.dart';
import '../../services/roadmap_service.dart';
import '../../models/roadmap_model.dart';
import '../common/glass_container.dart';

class DailyMissionsCard extends StatelessWidget {
  const DailyMissionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = GamificationService();

    return ListenableBuilder(
      listenable: gamification,
      builder: (context, _) {
        final activeSkill = gamification.data.activeRoadmapSkill;

        if (activeSkill == null || activeSkill.isEmpty) {
          return const SizedBox.shrink(); // No active roadmap yet
        }

        final roadmap = RoadmapService.generateRoadmap(activeSkill);
        if (roadmap == null) return const SizedBox.shrink();

        // Find up to 3 incomplete tasks
        final List<Map<String, String>> dailyMissions = _getMissions(roadmap, gamification);

        if (dailyMissions.isEmpty) {
          return const SizedBox.shrink(); // Roadmap fully completed!
        }

        return GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    "Daily Missions",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Complete these to earn bonus XP!",
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              ...dailyMissions.map((mission) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.bolt_rounded, color: Theme.of(context).primaryColor, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mission['title']!,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "From: ${mission['category']}",
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Reward Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "+50 XP",
                          style: GoogleFonts.poppins(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ).animate().fade().slideY(begin: 0.1, end: 0);
      },
    );
  }

  List<Map<String, String>> _getMissions(RoadmapModel roadmap, GamificationService gamification) {
    final List<Map<String, String>> missions = [];
    final skillName = roadmap.skill;

    void checkCategory(String categoryName, List<String> items) {
      for (int i = 0; i < items.length; i++) {
        if (missions.length >= 3) return; // Only 3 missions max
        final taskId = "${skillName}_${categoryName}_$i";
        if (!gamification.isTaskCompleted(taskId)) {
          missions.add({
            'title': items[i],
            'category': categoryName,
          });
        }
      }
    }

    checkCategory("Basics", roadmap.basics);
    checkCategory("Core Skills", roadmap.coreSkills);
    checkCategory("Beginner Projects", roadmap.beginnerProjects);
    checkCategory("Intermediate Projects", roadmap.intermediateProjects);
    checkCategory("Advanced Projects", roadmap.advancedProjects);
    checkCategory("Interview Prep", roadmap.interviewPrep);

    return missions;
  }
}
