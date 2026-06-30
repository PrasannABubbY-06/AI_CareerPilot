import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants/app_colors.dart';
import 'package:ai_careerpilot/config/app_theme_extension.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    color: Theme.of(context).primaryColor.withOpacity(0.06),
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
                  color: Theme.of(context).primaryColor,
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
                    color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
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
