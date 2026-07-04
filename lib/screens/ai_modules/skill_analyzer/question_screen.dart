import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/common/glass_container.dart';
import 'models/question_model.dart';

class QuestionScreen extends StatelessWidget {
  final List<QuestionModel> questions;
  final int currentIndex;
  final Function(int) onAnswer;

  const QuestionScreen({
    super.key,
    required this.questions,
    required this.currentIndex,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
        ),
      );
    }

    final q = questions[currentIndex];
    final progress = (currentIndex + 1) / questions.length;

    // Helper to get letters A, B, C, D
    String getOptionLetter(int index) {
      switch (index) {
        case 0:
          return "A";
        case 1:
          return "B";
        case 2:
          return "C";
        case 3:
          return "D";
        default:
          return "-";
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.06),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  
                  // Progress Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Assessment",
                        style: GoogleFonts.poppins(
                          color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        "${currentIndex + 1} of ${questions.length}",
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Glowing Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Question details header card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accentPink.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.accentPink.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt, color: AppColors.accentPink, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              q.level.toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: AppColors.accentPink,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Single Choice",
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Frosted glass question container
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    opacity: 0.05,
                    borderRadius: BorderRadius.circular(24),
                    child: Text(
                      q.question,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ).animate(key: ValueKey(currentIndex))
                   .fade(duration: 400.ms)
                   .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                  
                  const SizedBox(height: 32),
                  
                  // Options Vertical List
                  ...q.options.asMap().entries.map((e) {
                    final int idx = e.key;
                    final String optionText = e.value;
                    
                    return GestureDetector(
                      onTap: () => onAnswer(idx),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(18),
                          opacity: 0.04,
                          borderRadius: BorderRadius.circular(20),
                          child: Row(
                            children: [
                              // Letter Badge (A, B, C, D)
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    getOptionLetter(idx),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              
                              // Option Text
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate(key: ValueKey('opt_$idx'))
                     .fade(delay: (idx * 50).ms, duration: 400.ms)
                     .slideX(begin: 0.04, end: 0, curve: Curves.easeOutQuad);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
