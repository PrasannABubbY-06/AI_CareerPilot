import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../models/career_quiz_result_model.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../widgets/animations/three_d_tilt_wrapper.dart';
import '../../../services/career_journey_service.dart';
import 'quiz_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final CareerQuizResultModel result;

  const QuizResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    // Determine the max points out of all 4 domains for the percentage calculation
    final totalPoints = result.domainScores.values.fold(0.0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Career Decision Engine",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, "/dashboard", (route) => false);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Retake Quiz",
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const QuizScreen(isRetake: true)));
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: 40,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.08),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= OVERVIEW HERO =================
                ThreeDTiltWrapper(
                  child: GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    borderRadius: BorderRadius.circular(28),
                    child: Column(
                      children: [
                        Text(
                          "Top Domain Match",
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.primaryDomain.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: Colors.purpleAccent,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${result.suitabilityPercentage}% Suitability",
                          style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Domain Progress Bars
                        ...result.domainScores.entries.map((entry) {
                          double percent = totalPoints > 0 ? entry.value / totalPoints : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                                    Text("${(percent * 100).toInt()}%", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percent,
                                    backgroundColor: Colors.white12,
                                    color: entry.key == result.primaryDomain ? Colors.purpleAccent : Colors.white38,
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ).animate().fade(duration: 500.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                // ================= RECOMMENDED ROLES =================
                if (result.recommendedRoles.isNotEmpty) ...[
                  Text(
                    "Recommended Roles",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ).animate().fade(delay: 100.ms).slideX(),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: result.recommendedRoles.map((role) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          role,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ).animate().fade(delay: 200.ms).slideY(),
                  const SizedBox(height: 24),
                ],

                // ================= AI EXPLANATION =================
                Text(
                  "Why this fits you",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(delay: 200.ms).slideX(),
                const SizedBox(height: 12),
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(20),
                  child: Text(
                    result.explanation,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ).animate().fade(delay: 300.ms).slideY(),

                const SizedBox(height: 24),

                // ================= STRENGTHS & WEAKNESSES =================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildListSection(
                        "Strengths",
                        result.strengths,
                        Colors.greenAccent,
                        Icons.trending_up_rounded,
                      ),
                    ).animate().fade(delay: 400.ms).slideX(begin: -0.1),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildListSection(
                        "Growth Areas",
                        result.weaknesses,
                        Colors.orangeAccent,
                        Icons.trending_down_rounded,
                      ),
                    ).animate().fade(delay: 400.ms).slideX(begin: 0.1),
                  ],
                ),

                const SizedBox(height: 24),

                // ================= LEARNING ROADMAP =================
                if (result.learningRoadmap.isNotEmpty) ...[
                  Text(
                    "Recommended Roadmap",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade(delay: 500.ms).slideX(),
                  const SizedBox(height: 12),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...result.learningRoadmap.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    "${entry.key + 1}",
                                    style: GoogleFonts.poppins(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ).animate().fade(delay: 600.ms).slideY(),
                  const SizedBox(height: 24),
                ],

                // ================= NEXT SKILL CTA =================
                if (result.nextSkill.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                        shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      onPressed: () {
                        // Hook into CareerJourneyService
                        Provider.of<CareerJourneyService>(context, listen: false).startNewSkill(result.nextSkill);
                        Navigator.pushNamed(context, "/career-journey");
                      },
                      child: Text(
                        "Start Learning ${result.nextSkill}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ).animate().fade(delay: 700.ms).scale(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, Color color, IconData icon) {
    if (items.isEmpty) return const SizedBox();
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, color: color.withOpacity(0.5), size: 6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
