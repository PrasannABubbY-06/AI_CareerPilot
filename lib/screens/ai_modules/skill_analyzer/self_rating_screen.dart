import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/common/glass_container.dart';

class SelfRatingScreen extends StatefulWidget {
  final Function(Map<String, int>) onSubmit;

  const SelfRatingScreen({
    super.key,
    required this.onSubmit,
  });

  @override
  State<SelfRatingScreen> createState() => _SelfRatingScreenState();
}

class _SelfRatingScreenState extends State<SelfRatingScreen> {
  final Map<String, int> ratings = {
    "Problem Solving": 0,
    "Projects": 0,
    "Debugging": 0,
    "Architecture": 0,
    "Confidence": 0,
  };

  Widget buildRating(String skill, int idx) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        opacity: 0.04,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              skill,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final isSelected = ratings[skill]! > index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      ratings[skill] = index + 1;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.warning.withOpacity(0.12)
                          : Colors.white.withOpacity(0.02),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.warning.withOpacity(0.5)
                            : Colors.white.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isSelected ? AppColors.warning : Colors.white24,
                      size: 24,
                      shadows: isSelected
                          ? [
                              Shadow(
                                color: AppColors.warning.withOpacity(0.6),
                                blurRadius: 10,
                              )
                            ]
                          : [],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ).animate(delay: (idx * 60).ms)
       .fade(duration: 400.ms)
       .slideY(begin: 0.06, end: 0, curve: Curves.easeOutQuad),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        children: [
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
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      "STEP 5 OF 6",
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Rate Yourself",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade(duration: 400.ms),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: ratings.keys
                          .toList()
                          .asMap()
                          .entries
                          .map((e) => buildRating(e.value, e.key))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    text: "Continue",
                    onPressed: () {
                      widget.onSubmit(ratings);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
