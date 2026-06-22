import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/common/glass_container.dart';

class ExperienceScreen extends StatelessWidget {
  final Function(String) onNext;

  const ExperienceScreen({
    super.key,
    required this.onNext,
  });

  Widget buildCard(String text, IconData icon, Color color, int index) {
    return GestureDetector(
      onTap: () => onNext(text),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        opacity: 0.04,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white38,
            )
          ],
        ),
      ),
    ).animate(delay: (index * 80).ms)
     .fade(duration: 400.ms)
     .slideX(begin: 0.08, end: 0, curve: Curves.easeOutQuad);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: GlassContainer(
                  width: 420,
                  opacity: 0.03,
                  borderRadius: BorderRadius.circular(28),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          "STEP 3 OF 6",
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "What's Your Current Level?",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                      const SizedBox(height: 32),
                      buildCard(
                        "I'm Completely New",
                        Icons.rocket_launch_rounded,
                        AppColors.accentCyan,
                        0,
                      ),
                      const SizedBox(height: 14),
                      buildCard(
                        "I Know Basics",
                        Icons.menu_book_rounded,
                        AppColors.warning,
                        1,
                      ),
                      const SizedBox(height: 14),
                      buildCard(
                        "I Have Built Projects",
                        Icons.code_rounded,
                        AppColors.secondary,
                        2,
                      ),
                      const SizedBox(height: 14),
                      buildCard(
                        "Professional Experience",
                        Icons.work_rounded,
                        AppColors.success,
                        3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
