import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

import '../../../models/achievement_model.dart';
import '../../../widgets/common/glass_container.dart';

class AchievementPopup {
  static void show(BuildContext context, AchievementModel achievement) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Achievement",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _AchievementPopupOverlay(achievement: achievement);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
  }
}

class _AchievementPopupOverlay extends StatefulWidget {
  final AchievementModel achievement;

  const _AchievementPopupOverlay({required this.achievement});

  @override
  State<_AchievementPopupOverlay> createState() => _AchievementPopupOverlayState();
}

class _AchievementPopupOverlayState extends State<_AchievementPopupOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.amber, Colors.orange, Colors.yellow, Colors.white],
            ),
          ),
          
          Center(
            child: GlassContainer(
              padding: const EdgeInsets.all(32),
              borderRadius: BorderRadius.circular(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "ACHIEVEMENT UNLOCKED!",
                    style: GoogleFonts.poppins(
                      color: Colors.amberAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn().slideY(begin: -0.5),
                  
                  const SizedBox(height: 24),
                  
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.achievement.color.withValues(alpha: 0.2),
                      border: Border.all(color: widget.achievement.color, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: widget.achievement.color.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.achievement.icon,
                      size: 50,
                      color: widget.achievement.color,
                    ),
                  ).animate().scale(delay: 300.ms, curve: Curves.easeOutBack),

                  const SizedBox(height: 24),
                  
                  Text(
                    widget.achievement.title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    widget.achievement.description,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "+${widget.achievement.xpReward} XP",
                          style: GoogleFonts.poppins(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 800.ms).scale(),

                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("Awesome!"),
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
