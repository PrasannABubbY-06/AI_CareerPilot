import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../constants/app_colors.dart';
import '../../ai_modules/skill_analyzer/widgets/radar_chart.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/common/glass_container.dart';
import 'models/result_model.dart';
import 'models/roadmap_model.dart';
import 'services/roadmap_service.dart';
import 'package:ai_careerpilot/config/app_theme_extension.dart';

class ResultScreen extends StatelessWidget {
  final ResultModel? result;
  final VoidCallback onRestart;

  const ResultScreen({
    super.key,
    required this.result,
    required this.onRestart,
  });

  Color priorityColor(BuildContext context, String priority) {
    switch (priority) {
      case "High":
        return Theme.of(context).colorScheme.error;
      case "Medium":
        return Theme.of(context).extension<AppThemeExtension>()!.warning;
      default:
        return Theme.of(context).extension<AppThemeExtension>()!.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
        ),
      );
    }

    final strengths = RoadmapService.getStrengths(result!.skillScores);
    final gaps = RoadmapService.getGaps(result!.skillScores);
    final roadmap = RoadmapService.generateRoadmap(result!.skillScores);
    final level = RoadmapService.getLevel(result!.percentage);
    final totalHours = RoadmapService.calculateHours(roadmap);
    final readiness = RoadmapService.getReadinessScore(result!.skillScores);
    final nextSkill = RoadmapService.nextFocusArea(result!.skillScores);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.08),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.06),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= TITLE =================
                  Center(
                    child: Text(
                      "Skill Assessment Report",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= SCORE CARD =================
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    opacity: 0.04,
                    borderRadius: BorderRadius.circular(28),
                    child: Column(
                      children: [
                        // Large circle score indicator
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: Theme.of(context).extension<AppThemeExtension>()!.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "${result!.percentage.toStringAsFixed(0)}%",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        Text(
                          level.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Divider(color: Colors.white.withOpacity(0.08)),
                        
                        const SizedBox(height: 12),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Job Readiness Score",
                              style: GoogleFonts.poppins(
                                color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "${readiness.toStringAsFixed(0)}%",
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).extension<AppThemeExtension>()!.success,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 500.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 32),

                  // ================= RADAR CHART =================
                  Text(
                    "Skill Radar Analysis",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    opacity: 0.03,
                    borderRadius: BorderRadius.circular(24),
                    child: Center(
                      child: RadarChartWidget(
                        data: result!.skillScores.isEmpty
                            ? {
                                "UI Development": 0,
                                "State Management": 0,
                                "Firebase": 0,
                                "API Integration": 0,
                                "Architecture": 0,
                              }
                            : result!.skillScores,
                      ),
                    ),
                  ).animate().fade(delay: 100.ms, duration: 400.ms),

                  const SizedBox(height: 32),

                  // ================= STRENGTHS & GAPS =================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Strengths
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Strengths",
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).extension<AppThemeExtension>()!.success,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...strengths.map(
                              (skill) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded,
                                        color: Theme.of(context).extension<AppThemeExtension>()!.success, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        skill,
                                        style: GoogleFonts.poppins(
                                            color: Colors.white, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 16),

                      // Gaps
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Skill Gaps",
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...gaps.map(
                              (skill) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Icon(Icons.cancel_outlined,
                                        color: Theme.of(context).colorScheme.error, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        skill,
                                        style: GoogleFonts.poppins(
                                            color: Colors.white, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 200.ms, duration: 450.ms),

                  const SizedBox(height: 32),

                  // ================= NEXT FOCUS =================
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    opacity: 0.05,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).extension<AppThemeExtension>()!.warning.withOpacity(0.25),
                      width: 1,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: Theme.of(context).extension<AppThemeExtension>()!.warning, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Next Focus Area",
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).extension<AppThemeExtension>()!.warning,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nextSkill,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: 32),

                  // ================= ROADMAP =================
                  Text(
                    "Personalized Roadmap",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  ...roadmap.asMap().entries.map(
                    (entry) {
                      final idx = entry.key;
                      final RoadmapModel item = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(18),
                          opacity: 0.04,
                          borderRadius: BorderRadius.circular(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.module,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.description,
                                style: GoogleFonts.poppins(
                                  color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: priorityColor(context, item.priority).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: priorityColor(context, item.priority).withOpacity(0.3),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      "${item.priority} Priority",
                                      style: GoogleFonts.poppins(
                                        color: priorityColor(context, item.priority),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${item.hours} Hours Estimated",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ).animate(delay: (idx * 80).ms)
                       .fade(duration: 400.ms)
                       .slideY(begin: 0.08, end: 0);
                    },
                  ),

                  const SizedBox(height: 20),

                  // ================= TOTAL HOURS =================
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "Estimated Learning Time: $totalHours Hours",
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ================= RESTART =================
                  PrimaryButton(
                    text: "Start Assessment Again",
                    onPressed: onRestart,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}