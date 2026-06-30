import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../constants/app_colors.dart';
import '../../models/roadmap_model.dart';
import '../../services/roadmap_service.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/glass_container.dart';
import 'package:ai_careerpilot/config/app_theme_extension.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final TextEditingController skillController = TextEditingController();
  RoadmapModel? roadmap;

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
  }

  Widget buildSection(String title, List<String> items, int index) {
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
                    color: Theme.of(context).primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.35),
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
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Theme.of(context).extension<AppThemeExtension>()!.success,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(delay: (index * 80).ms, duration: 400.ms).slideY(begin: 0.08, end: 0);
  }

  @override
  Widget build(BuildContext context) {
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
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.06),
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
                const SizedBox(height: 20),
                
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
                                  color: Theme.of(context).extension<AppThemeExtension>()!.success.withOpacity(0.12),
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
                              value: 0.25,
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
                                "25% Learning Progress",
                                style: GoogleFonts.poppins(
                                  color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "1 of 4 Steps Complete",
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

                  const SizedBox(height: 16),

                  buildSection("Basics", roadmap!.basics, 0),
                  buildSection("Core Skills", roadmap!.coreSkills, 1),
                  buildSection("Beginner Projects", roadmap!.beginnerProjects, 2),
                  buildSection("Intermediate Projects", roadmap!.intermediateProjects, 3),
                  buildSection("Advanced Projects", roadmap!.advancedProjects, 4),
                  buildSection("Interview Preparation", roadmap!.interviewPrep, 5),
                  
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
