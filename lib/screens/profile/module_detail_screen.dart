import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/glass_container.dart';
import 'package:ai_careerpilot/config/app_theme_extension.dart';

class ModuleDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;
  final List<String> workflow;
  final String benefit;

  const ModuleDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
    required this.workflow,
    required this.benefit,
  });

  Widget _buildSectionTitle(String text, IconData sectionIcon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 24),
      child: Row(
        children: [
          Icon(sectionIcon, color: color, size: 22),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Module Details",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: 0,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withOpacity(0.3), width: 2),
                    ),
                    child: Icon(icon, color: color, size: 54),
                  ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0, delay: 200.ms),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ).animate().fade(delay: 300.ms),

                const SizedBox(height: 16),
                const Divider(color: Colors.white12),

                // Features
                _buildSectionTitle("Key Features", Icons.star_rounded).animate().fade(delay: 400.ms),
                ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded, color: color, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          f,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList().animate(interval: 100.ms).fade(delay: 500.ms).slideX(begin: 0.1, end: 0),

                // Workflow
                _buildSectionTitle("How It Works", Icons.account_tree_rounded).animate().fade(delay: 600.ms),
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  opacity: 0.04,
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: workflow.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "${index + 1}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (index != workflow.length - 1)
                                Container(
                                  width: 2,
                                  height: 30,
                                  color: color.withOpacity(0.3),
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 16),
                              child: Text(
                                step,
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ).animate().fade(delay: 700.ms).slideY(begin: 0.1, end: 0),

                // Benefits
                _buildSectionTitle("Ultimate Benefit", Icons.workspace_premium_rounded).animate().fade(delay: 800.ms),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: color, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          benefit,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(delay: 900.ms).scale(begin: const Offset(0.95, 0.95)),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
