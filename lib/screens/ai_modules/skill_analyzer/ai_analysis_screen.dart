import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants/app_colors.dart';

class AiAnalysisScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const AiAnalysisScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
      widget.onComplete,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        children: [
          // Radial Ambient Glow
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Futuristic double bounce loader
                SpinKitDoubleBounce(
                  color: AppColors.primary,
                  size: 80.0,
                ).animate()
                 .scale(duration: 400.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 40),

                // Main message
                Text(
                  "AI System Initializing...",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ).animate()
                 .fade(delay: 200.ms, duration: 450.ms)
                 .slideY(begin: 0.15, end: 0, curve: Curves.easeOutQuad),

                const SizedBox(height: 10),

                // Secondary status text
                Text(
                  "Preparing custom skill assessment",
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ).animate()
                 .fade(delay: 450.ms, duration: 450.ms)
                 .slideY(begin: 0.15, end: 0, curve: Curves.easeOutQuad),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
