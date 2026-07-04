import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/gamification_model.dart';
import '../common/glass_container.dart';

class ProgressOverviewCard extends StatelessWidget {
  final GamificationModel data;

  const ProgressOverviewCard({super.key, required this.data});

  String _getRank(int level) {
    if (level < 5) return "Bronze Explorer";
    if (level < 15) return "Silver Achiever";
    if (level < 30) return "Gold Professional";
    if (level < 50) return "Platinum Expert";
    return "Diamond Master";
  }

  @override
  Widget build(BuildContext context) {
    final xpForNextLevel = data.level * 100; // Base 100 multiplier
    final progress = (data.xp / xpForNextLevel).clamp(0.0, 1.0);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progress Overview",
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getRank(data.level),
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(context, Icons.star_rounded, Colors.amber, "Level ${data.level}", "Current"),
              _buildStatColumn(context, Icons.local_fire_department_rounded, Colors.orange, "${data.streakDays} Days", "Streak"),
              _buildStatColumn(context, Icons.monetization_on_rounded, Colors.yellow[700]!, "${data.coins}", "Coins"),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "XP to Level ${data.level + 1}",
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              Text(
                "${data.xp} / $xpForNextLevel XP",
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, IconData icon, Color color, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
