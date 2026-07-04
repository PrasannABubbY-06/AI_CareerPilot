import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/common/glass_container.dart';
import 'voice_interview_service.dart';
import 'package:ai_careerpilot/config/app_theme_extension.dart';

class VoiceInterviewScreen extends StatefulWidget {
  const VoiceInterviewScreen({super.key});

  @override
  State<VoiceInterviewScreen> createState() => _VoiceInterviewScreenState();
}

class _VoiceInterviewScreenState extends State<VoiceInterviewScreen> {
  final service = VoiceInterviewService();

  String question = "Tell me about yourself";
  String answer = "";
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    service.init().then((_) {
      service.speak(question);
    });
  }

  Future<void> startListening() async {
    setState(() {
      isListening = true;
      answer = "Listening...";
    });
    
    final result = await service.listen();

    setState(() {
      answer = result;
      isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Voice Interview",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: 60,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                    blurRadius: 110,
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Question Title Header
                Text(
                  "CURRENT QUESTION",
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                
                const SizedBox(height: 12),

                // Question Text Card
                GlassContainer(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  opacity: 0.05,
                  borderRadius: BorderRadius.circular(24),
                  child: Text(
                    question,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ).animate().fade(duration: 400.ms),

                const SizedBox(height: 48),

                // Mic Pulse Buttons
                GestureDetector(
                  onTap: isListening ? null : startListening,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isListening)
                        ...List.generate(3, (index) {
                          return Container(
                            width: 90.0 + (index * 20.0),
                            height: 90.0 + (index * 20.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.12 - (index * 0.03)),
                            ),
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                           .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: (800 + index * 200).ms, curve: Curves.easeInOut);
                        }),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: Theme.of(context).extension<AppThemeExtension>()!.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  isListening ? "Listening... Speak now" : "Tap Mic To Start Answering",
                  style: GoogleFonts.poppins(
                    color: isListening ? Theme.of(context).extension<AppThemeExtension>()!.success : (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 48),

                // User Answer Header
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Your Answer:",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // User Answer Text Card
                Expanded(
                  child: GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    opacity: 0.03,
                    borderRadius: BorderRadius.circular(24),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        answer.isEmpty ? "Your spoken answer will appear here..." : answer,
                        style: GoogleFonts.poppins(
                          color: answer.isEmpty ? Colors.white30 : Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),

                PrimaryButton(
                  text: "Next Question",
                  onPressed: isListening ? null : () {
                    // Back logic or next question mapping
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}