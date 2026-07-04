import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../config/app_theme_extension.dart';
import '../../services/groq_service.dart';
import '../../services/gamification_service.dart';
import '../animations/three_d_tilt_wrapper.dart';

class AiMentorHeader extends StatefulWidget {
  final GamificationService gamification;

  const AiMentorHeader({super.key, required this.gamification});

  @override
  State<AiMentorHeader> createState() => _AiMentorHeaderState();
}

class _AiMentorHeaderState extends State<AiMentorHeader> {
  String userName = "Explorer";
  String motivationMessage = "Loading your daily motivation... 🚀";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null && doc.data()!['name'] != null) {
          userName = doc.data()!['name'].toString().split(" ").first; // Get first name
        } else if (user.displayName != null && user.displayName!.isNotEmpty) {
          userName = user.displayName!.split(" ").first;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month}-${now.day}";
      
      final cachedDate = prefs.getString('motivation_date');
      final cachedMsg = prefs.getString('motivation_msg');

      if (cachedDate == todayStr && cachedMsg != null && cachedMsg.isNotEmpty) {
        motivationMessage = cachedMsg;
      } else {
        // Fetch new motivation
        final level = widget.gamification.data.level;
        final streak = widget.gamification.data.streakDays;
        final goal = widget.gamification.data.careerGoal;
        
        final msg = await GroqService().generateDailyMotivation(userName, level, streak, goal);
        
        if (!msg.contains("Error")) {
          motivationMessage = msg.replaceAll('"', '');
          await prefs.setString('motivation_date', todayStr);
          await prefs.setString('motivation_msg', motivationMessage);
        } else {
          motivationMessage = "Keep pushing forward, $userName! Every step counts towards your ultimate career goal. 🔥";
        }
      }
    } catch (e) {
      motivationMessage = "Ready to conquer the day? Let's build your career! 🌟";
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    return ThreeDTiltWrapper(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: Theme.of(context).extension<AppThemeExtension>()!.primaryGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                "AI MENTOR ACTIVE ⚡",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "${_getGreeting()},\n$userName 👋",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.2,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            motivationMessage,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
  }
}
