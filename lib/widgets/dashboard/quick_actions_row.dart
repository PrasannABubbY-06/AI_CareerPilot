import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildActionChip(
                context,
                "Career Quiz",
                Icons.quiz_rounded,
                Colors.purple,
                () => Navigator.pushNamed(context, "/career-quiz"),
              ),
              _buildActionChip(
                context,
                "Journey Map",
                Icons.map_rounded,
                Colors.orange,
                () => Navigator.pushNamed(context, "/career-journey"),
              ),
              _buildActionChip(
                context,
                "Weekly Report",
                Icons.analytics_rounded,
                Colors.blueAccent,
                () => Navigator.pushNamed(context, "/weekly-report"),
              ),
              _buildActionChip(
                context,
                "Roadmap",
                Icons.list_alt_rounded,
                Colors.green,
                () => Navigator.pushNamed(context, "/roadmap"),
              ),
              _buildActionChip(
                context,
                "Skill Analyzer",
                Icons.insights_rounded,
                Colors.teal,
                () => Navigator.pushNamed(context, "/skill-analyzer"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
