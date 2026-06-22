import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../constants/app_colors.dart';
import '../../widgets/common/glass_container.dart';

class RecruiterDashboard extends StatelessWidget {
  const RecruiterDashboard({super.key});

  Widget buildCard({
    required String title,
    required String subtitle,
    required Widget child,
    required int index,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      opacity: 0.04,
      borderRadius: BorderRadius.circular(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    ).animate(delay: (index * 100).ms)
     .fade(duration: 400.ms)
     .slideY(begin: 0.08, end: 0);
  }

  Widget skillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Text(
        skill,
        style: GoogleFonts.poppins(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget candidateTile({
    required String name,
    required int score,
    required String role,
  }) {
    final bool isExcellent = score >= 80;
    final scoreColor = isExcellent ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.12),
              child: Text(
                name[0],
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: scoreColor.withOpacity(0.45),
                width: 1,
              ),
            ),
            child: Text(
              "$score%",
              style: GoogleFonts.poppins(
                color: scoreColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget shortlistTile(String name, String skill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  skill,
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Recruiter Dashboard",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: 40,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.05),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Layout grid: Candidate scores & shortlists
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildCard(
                          title: "ATS Scores",
                          subtitle: "Top performing applicants",
                          index: 0,
                          child: Column(
                            children: [
                              candidateTile(
                                name: "Rahul Sharma",
                                score: 92,
                                role: "Flutter Developer",
                              ),
                              candidateTile(
                                name: "Sneha Reddy",
                                score: 88,
                                role: "Backend Developer",
                              ),
                              candidateTile(
                                name: "Arjun Kumar",
                                score: 79,
                                role: "UI/UX Designer",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        buildCard(
                          title: "Shortlist",
                          subtitle: "AI shortlisted candidates",
                          index: 1,
                          child: Column(
                            children: [
                              shortlistTile("Rahul Sharma", "Flutter • Firebase"),
                              shortlistTile("Sneha Reddy", "Node.js • MongoDB"),
                              shortlistTile("Arjun Kumar", "Figma • UX Research"),
                              shortlistTile("Meghana", "AWS • DevOps"),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Layout grid: Heatmaps & AI insights
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildCard(
                          title: "Skill Heatmap",
                          subtitle: "Trending candidate skills",
                          index: 2,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              skillChip("Flutter"),
                              skillChip("Firebase"),
                              skillChip("React"),
                              skillChip("Node.js"),
                              skillChip("AWS"),
                              skillChip("Docker"),
                              skillChip("Figma"),
                              skillChip("Python"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        buildCard(
                          title: "AI Insights",
                          subtitle: "Smart hiring insights",
                          index: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              recommendationTile(
                                Icons.star_rounded,
                                "Candidates with Flutter + Firebase skills are highly suitable.",
                              ),
                              recommendationTile(
                                Icons.psychology_rounded,
                                "Top ATS resumes contain measurable achievements.",
                              ),
                              recommendationTile(
                                Icons.trending_up_rounded,
                                "AI predicts 84% hiring success for shortlisted applicants.",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget recommendationTile(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}