import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/roadmap_model.dart';
import '../../services/roadmap_service.dart';
import '../../services/gamification_service.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/gamification/gamification_header.dart';
import '../../widgets/gamification/daily_missions_card.dart';
import 'package:ai_careerpilot/config/app_theme_extension.dart';
import 'package:confetti/confetti.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final TextEditingController skillController = TextEditingController();
  RoadmapModel? roadmap;
  late ConfettiController _confettiController;
  final GamificationService _gamification = GamificationService();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    skillController.dispose();
    super.dispose();
  }

  void generateRoadmap() {
    final skill = skillController.text.trim();

    if (skill.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a skill", style: GoogleFonts.poppins()),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final generatedRoadmap = RoadmapService.generateRoadmap(skill);

    if (generatedRoadmap == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          content: Text("Skill not supported yet", style: GoogleFonts.poppins()),
        ),
      );

      setState(() {
        roadmap = null;
      });
      return;
    }

    setState(() {
      roadmap = generatedRoadmap;
    });
    
    // Set active roadmap for daily missions
    _gamification.setActiveRoadmapSkill(generatedRoadmap.skill);
  }

  void _toggleTask(String taskId, bool isCompleted) async {
    if (isCompleted) {
      bool leveledUp = await _gamification.completeTask(taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber),
                const SizedBox(width: 8),
                Text("+50 XP Earned!", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ],
            ),
            backgroundColor: Theme.of(context).extension<AppThemeExtension>()!.success,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (leveledUp) {
          _confettiController.play();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text("🎉 Level Up! 🎉", style: GoogleFonts.poppins(color: Colors.white)),
              content: Text("You reached Level ${_gamification.data.level}!", style: GoogleFonts.poppins(color: Colors.grey)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Awesome!", style: GoogleFonts.poppins(color: Theme.of(context).primaryColor)),
                ),
              ],
            ),
          );
        }
      }
    } else {
      await _gamification.uncompleteTask(taskId);
    }
    setState(() {}); // Rebuild to show checkmark
  }

  Widget buildSection(String title, String categoryKey, List<String> items, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        opacity: 0.04,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    "STEP ${index + 1}",
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final taskId = "${roadmap!.skill}_${categoryKey}_$idx";
              final isCompleted = _gamification.isTaskCompleted(taskId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _toggleTask(taskId, !isCompleted),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Theme.of(context).extension<AppThemeExtension>()!.success.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCompleted 
                            ? Theme.of(context).extension<AppThemeExtension>()!.success.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: isCompleted ? Theme.of(context).extension<AppThemeExtension>()!.success : Colors.grey,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: isCompleted 
                                  ? Colors.white 
                                  : (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                              height: 1.4,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (isCompleted)
                          Text(
                            "+50 XP",
                            style: GoogleFonts.poppins(
                              color: Colors.amber,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fade().slideY(begin: 0.5, end: 0),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total roadmap progress if generated
    double totalProgress = 0.0;
    int completedCount = 0;
    int totalCount = 0;
    if (roadmap != null) {
      final allItems = [
        ...roadmap!.basics.map((e) => "${roadmap!.skill}_Basics_${roadmap!.basics.indexOf(e)}"),
        ...roadmap!.coreSkills.map((e) => "${roadmap!.skill}_Core Skills_${roadmap!.coreSkills.indexOf(e)}"),
        ...roadmap!.beginnerProjects.map((e) => "${roadmap!.skill}_Beginner Projects_${roadmap!.beginnerProjects.indexOf(e)}"),
        ...roadmap!.intermediateProjects.map((e) => "${roadmap!.skill}_Intermediate Projects_${roadmap!.intermediateProjects.indexOf(e)}"),
        ...roadmap!.advancedProjects.map((e) => "${roadmap!.skill}_Advanced Projects_${roadmap!.advancedProjects.indexOf(e)}"),
        ...roadmap!.interviewPrep.map((e) => "${roadmap!.skill}_Interview Prep_${roadmap!.interviewPrep.indexOf(e)}"),
      ];
      totalCount = allItems.length;
      completedCount = allItems.where((id) => _gamification.isTaskCompleted(id)).length;
      if (totalCount > 0) {
        totalProgress = completedCount / totalCount;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Career Roadmap",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: 100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.06),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),
          
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 16),
                
                // GAMIFICATION HEADER
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: GamificationHeader(),
                ),
                const SizedBox(height: 24),
                
                // Header Titles
                Text(
                  "Enter Your Skill",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  "Get Complete Beginner to Advanced Roadmap",
                  style: GoogleFonts.poppins(color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),

                // Custom Input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomTextField(
                    controller: skillController,
                    hintText: "Flutter, Python, AI, Java, Frontend",
                    prefixIcon: Icons.school_outlined,
                  ),
                ),
                
                const SizedBox(height: 20),

                // Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PrimaryButton(
                    text: "Generate Roadmap",
                    onPressed: generateRoadmap,
                    width: 240,
                    height: 52,
                  ),
                ),

                const SizedBox(height: 32),

                // Roadmap Results
                if (roadmap != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassContainer(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      opacity: 0.05,
                      borderRadius: BorderRadius.circular(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                roadmap!.skill,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).extension<AppThemeExtension>()!.success.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Active",
                                  style: GoogleFonts.poppins(
                                    color: Theme.of(context).extension<AppThemeExtension>()!.success,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: totalProgress,
                              minHeight: 8,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).extension<AppThemeExtension>()!.success),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${(totalProgress * 100).toInt()}% Learning Progress",
                                style: GoogleFonts.poppins(
                                  color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "$completedCount of $totalCount Steps Complete",
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(duration: 400.ms),

                  const SizedBox(height: 20),

                  // DAILY MISSIONS
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: DailyMissionsCard(),
                  ),

                  const SizedBox(height: 20),

                  buildSection("Basics", "Basics", roadmap!.basics, 0),
                  buildSection("Core Skills", "Core Skills", roadmap!.coreSkills, 1),
                  buildSection("Beginner Projects", "Beginner Projects", roadmap!.beginnerProjects, 2),
                  buildSection("Intermediate Projects", "Intermediate Projects", roadmap!.intermediateProjects, 3),
                  buildSection("Advanced Projects", "Advanced Projects", roadmap!.advancedProjects, 4),
                  buildSection("Interview Preparation", "Interview Prep", roadmap!.interviewPrep, 5),
                  
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
          
          // CONFETTI OVERLAY
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }
}
