import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../models/achievement_model.dart';
import '../../../services/gamification_service.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../widgets/animations/three_d_tilt_wrapper.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final GamificationService _gamification = GamificationService();

  @override
  void initState() {
    super.initState();
    _gamification.addListener(_updateState);
  }

  @override
  void dispose() {
    _gamification.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final unlockedIds = _gamification.data.achievements;
    final allAchievements = AchievementModel.allAchievements;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Achievements",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amberAccent.withValues(alpha: 0.08),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "${unlockedIds.length} / ${allAchievements.length}",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fade().slideY(),
                      Text(
                        "Badges Unlocked",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ).animate().fade(delay: 100.ms),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: unlockedIds.length / allAchievements.length,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                          minHeight: 8,
                        ),
                      ).animate().fade(delay: 200.ms),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final badge = allAchievements[index];
                      final isUnlocked = unlockedIds.contains(badge.id);

                      return _buildBadgeCard(badge, isUnlocked, index);
                    },
                    childCount: allAchievements.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(AchievementModel badge, bool isUnlocked, int index) {
    return ThreeDTiltWrapper(
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(16),
        border: Border.all(
          color: isUnlocked ? badge.color.withValues(alpha: 0.5) : Colors.white12,
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: isUnlocked
            ? [BoxShadow(color: badge.color.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 2)]
            : [],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked ? badge.color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
              ),
              child: Icon(
                isUnlocked ? badge.icon : Icons.lock_rounded,
                color: isUnlocked ? badge.color : Colors.white24,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.title,
              style: GoogleFonts.poppins(
                color: isUnlocked ? Colors.white : Colors.white38,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              style: GoogleFonts.poppins(
                color: isUnlocked ? Colors.white70 : Colors.white24,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "+${badge.xpReward} XP",
                  style: GoogleFonts.poppins(
                    color: Colors.amberAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.1);
  }
}
