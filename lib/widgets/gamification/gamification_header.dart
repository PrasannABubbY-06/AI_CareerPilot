import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/gamification_service.dart';
import '../common/glass_container.dart';

class GamificationHeader extends StatelessWidget {
  const GamificationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final service = GamificationService();

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final data = service.data;
        final progress = service.levelProgress;

        return GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // Top Row: Level & XP, Streak, Coins
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Level Badge & XP
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            "${data.level}",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Level ${data.level}",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${data.xp} / ${service.xpForNextLevel} XP",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Streak and Coins
                  Row(
                    children: [
                      _buildStatBadge(
                        context,
                        icon: Icons.local_fire_department_rounded,
                        color: Colors.orangeAccent,
                        value: "${data.streakDays}",
                        label: "Streak",
                      ),
                      const SizedBox(width: 8),
                      _buildStatBadge(
                        context,
                        icon: Icons.monetization_on_rounded,
                        color: Colors.amber,
                        value: "${data.coins}",
                        label: "Coins",
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // XP Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ).animate().fade().slideY(begin: -0.1, end: 0);
      },
    );
  }

  Widget _buildStatBadge(BuildContext context, {
    required IconData icon, 
    required Color color, 
    required String value, 
    required String label
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
