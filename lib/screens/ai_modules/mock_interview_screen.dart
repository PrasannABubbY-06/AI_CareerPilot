import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../services/interview_ai_service.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/glass_container.dart';
import 'package:ai_careerpilot/config/app_theme_extension.dart';

class MockInterviewScreen extends StatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  // ================= SERVICES =================
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final InterviewAiService aiService = InterviewAiService();

  // ================= CONTROLLERS =================
  final TextEditingController roleController = TextEditingController();

  // ================= STATES =================
  bool isListening = false;
  bool isLoading = false;
  bool interviewStarted = false;
  String selectedLevel = "Beginner";
  String userAnswer = "";
  String currentQuestion = "";
  String aiFeedback = "";
  int currentQuestionIndex = 0;
  int confidenceScore = 0;
  List<String> questions = [];

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    initTTS();
  }

  Future<void> initTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
  }

  // ================= START INTERVIEW =================
  Future<void> startInterview() async {
    if (roleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Enter role first", style: GoogleFonts.poppins()),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      interviewStarted = false;
    });

    try {
      questions = await aiService.generateQuestions(
        role: roleController.text,
        level: selectedLevel,
      );

      if (questions.isEmpty) {
        questions = ["Tell me about yourself."];
      }

      setState(() {
        interviewStarted = true;
        currentQuestionIndex = 0;
        currentQuestion = questions[0];
        confidenceScore = 0;
        userAnswer = "";
        aiFeedback = "";
        isLoading = false;
      });

      await speakQuestion();
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e", style: GoogleFonts.poppins()),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ================= SPEAK QUESTION =================
  Future<void> speakQuestion() async {
    await _tts.stop();
    await _tts.speak(currentQuestion);
  }

  // ================= START MIC =================
  Future<void> startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        debugPrint("Speech status: $status");
      },
      onError: (error) {
        debugPrint("Speech error: $error");
      },
    );

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Speech recognition not available", style: GoogleFonts.poppins()),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isListening = true;
      userAnswer = "";
    });

    _speech.listen(
      onResult: (result) {
        setState(() {
          userAnswer = result.recognizedWords;
        });
      },
    );
  }

  // ================= STOP MIC =================
  Future<void> stopListening() async {
    await _speech.stop();

    setState(() {
      isListening = false;
    });

    confidenceScore = aiService.analyzeConfidence(userAnswer);

    aiFeedback = aiService.generateFeedback(
      answer: userAnswer,
      score: confidenceScore,
    );

    setState(() {});
  }

  // ================= NEXT QUESTION =================
  Future<void> nextQuestion() async {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        currentQuestion = questions[currentQuestionIndex];
        userAnswer = "";
        aiFeedback = "";
      });

      await speakQuestion();
    } else {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            title: Text(
              "Interview Completed 🎉",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "Final Confidence Score: $confidenceScore%\n\nExcellent practice session completed.",
              style: GoogleFonts.poppins(
                color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "OK",
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "AI Mock Interview",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: 40,
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
          
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HERO =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: Theme.of(context).extension<AppThemeExtension>()!.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AI Voice Interview 🚀",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Real-time AI generated interview questions based on your role and level.",
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ================= ROLE =================
                CustomTextField(
                  controller: roleController,
                  hintText: "Enter Role (Flutter Developer)",
                  prefixIcon: Icons.work_outline_rounded,
                ),

                const SizedBox(height: 16),

                // ================= LEVEL =================
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: const Color(0xFF0C101B),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedLevel,
                    dropdownColor: const Color(0xFF0C101B),
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0C101B),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    items: ["Beginner", "Intermediate", "Advanced"].map((level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(
                          level,
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLevel = value.toString();
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ================= START BUTTON =================
                PrimaryButton(
                  text: isLoading ? "Generating AI Questions..." : "Start Interview",
                  isLoading: isLoading,
                  onPressed: startInterview,
                ),

                const SizedBox(height: 32),

                // ================= INTERVIEW UI =================
                if (interviewStarted) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Question ${currentQuestionIndex + 1} of ${questions.length}",
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      IconButton(
                        onPressed: speakQuestion,
                        icon: const Icon(Icons.volume_up_rounded, color: Colors.white70),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // QUESTION CARD
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    opacity: 0.05,
                    borderRadius: BorderRadius.circular(24),
                    child: Text(
                      currentQuestion,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ).animate().fade(duration: 400.ms).slideY(begin: 0.08, end: 0),

                  const SizedBox(height: 32),

                  // MIC BUTTON (Glowing & Pulsing)
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: isListening ? stopListening : startListening,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (isListening)
                                ...List.generate(3, (index) {
                                  return Container(
                                    width: 80.0 + (index * 20.0),
                                    height: 80.0 + (index * 20.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.12 - (index * 0.03)),
                                    ),
                                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                                   .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: (1000 + index * 200).ms, curve: Curves.easeInOut);
                                }),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: isListening
                                      ? const LinearGradient(colors: [Colors.red, Color(0xFFEF4444)])
                                      : Theme.of(context).extension<AppThemeExtension>()!.primaryGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isListening ? Colors.red : Theme.of(context).primaryColor).withValues(alpha: 0.35),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isListening ? Icons.stop_rounded : Icons.mic_rounded,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          isListening ? "Listening... Tap to stop" : "Tap Mic To Answer",
                          style: GoogleFonts.poppins(
                            color: isListening ? Theme.of(context).colorScheme.error : (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ANSWER DISPLAY
                  Text(
                    "Your Answer",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    opacity: 0.03,
                    borderRadius: BorderRadius.circular(20),
                    child: Text(
                      userAnswer.isEmpty ? "Your answer will appear here..." : userAnswer,
                      style: GoogleFonts.poppins(
                        color: userAnswer.isEmpty ? (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey).withValues(alpha: 0.7) : Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // CONFIDENCE BAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Confidence Level",
                        style: GoogleFonts.poppins(
                          color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "$confidenceScore%",
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).extension<AppThemeExtension>()!.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: confidenceScore / 100,
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).extension<AppThemeExtension>()!.success),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // AI FEEDBACK
                  if (aiFeedback.isNotEmpty) ...[
                    GlassContainer(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      opacity: 0.05,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.psychology_rounded, color: Theme.of(context).colorScheme.secondary, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                "AI Feedback Analysis",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            aiFeedback,
                            style: GoogleFonts.poppins(
                              color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                              fontSize: 13.5,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 400.ms),
                    const SizedBox(height: 28),
                  ],

                  // NEXT BUTTON
                  PrimaryButton(
                    text: currentQuestionIndex == questions.length - 1 ? "Finish Interview" : "Next Question",
                    onPressed: nextQuestion,
                    gradient: Theme.of(context).extension<AppThemeExtension>()!.primaryGradient,
                  ),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}