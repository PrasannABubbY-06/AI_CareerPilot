import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme_extension.dart';
import '../../models/gamification_model.dart';
import '../common/glass_container.dart';

class YesterdaySummaryCard extends StatelessWidget {
  final GamificationModel data;

  const YesterdaySummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.yesterdayXp == 0 && data.yesterdayTasks.isEmpty) {
      return const SizedBox.shrink(); // Hide if nothing was done yesterday
    }

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).extension<AppThemeExtension>()!.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).extension<AppThemeExtension>()!.success,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Yesterday's Wins",
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Earned ${data.yesterdayXp} XP • Completed ${data.yesterdayTasks.length} tasks",
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
