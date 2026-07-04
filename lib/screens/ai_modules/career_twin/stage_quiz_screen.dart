import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../widgets/common/glass_container.dart';
import '../../../services/groq_service.dart';
import '../../../services/career_journey_service.dart';

class StageQuizScreen extends StatefulWidget {
  final String skillName;
  final int levelIndex;
  final String stageName;

  const StageQuizScreen({
    super.key,
    required this.skillName,
    required this.levelIndex,
    required this.stageName,
  });

  @override
  State<StageQuizScreen> createState() => _StageQuizScreenState();
}

class _StageQuizScreenState extends State<StageQuizScreen> {
  bool _isLoading = true;
  List<dynamic> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOption;
  bool _isAnswerChecked = false;
  bool _quizFinished = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final response = await GroqService().generateStageQuiz(widget.skillName, widget.levelIndex);
    
    // Robust parsing
    try {
      String cleanedJson = response.trim();
      final match = RegExp(r'\[[\s\S]*\]').firstMatch(cleanedJson);
      if (match != null) {
        cleanedJson = match.group(0)!;
      }
      final data = json.decode(cleanedJson);
      if (data is List && data.isNotEmpty) {
        _questions = data;
      }
    } catch (e) {
      debugPrint("Quiz parsing error: \$e");
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkAnswer() {
    if (_selectedOption == null) return;
    
    final correctIndex = _questions[_currentIndex]['correctIndex'] as int;
    if (_selectedOption == correctIndex) {
      _score++;
    }

    setState(() {
      _isAnswerChecked = true;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _isAnswerChecked = false;
      });
    } else {
      setState(() {
        _quizFinished = true;
      });
    }
  }

  void _finishQuiz() {
    // 80% passing rule? If 3 questions, need 3/3. Or just > 0. Let's say all correct for now since it's 3 questions.
    // Or let's say >= 2/3 is passing (66%).
    double passingPercentage = 0.66;
    if ((_score / _questions.length) >= passingPercentage) {
      // Pass
      Provider.of<CareerJourneyService>(context, listen: false).completeStageAndUnlockNext();
      Navigator.pop(context); // Go back to journey hub
    } else {
      // Fail - retry
      setState(() {
        _currentIndex = 0;
        _score = 0;
        _selectedOption = null;
        _isAnswerChecked = false;
        _quizFinished = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Text("Failed to load quiz. Please try again.", style: GoogleFonts.poppins(color: Colors.white)),
        ),
      );
    }

    if (_quizFinished) {
      bool passed = (_score / _questions.length) >= 0.66;
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passed ? Icons.emoji_events_rounded : Icons.cancel_rounded,
                color: passed ? Colors.amber : Colors.redAccent,
                size: 100,
              ),
              const SizedBox(height: 20),
              Text(
                passed ? "Stage Passed! 🎉" : "Keep Practicing! 💪",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "You scored $_score / ${_questions.length}",
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: passed ? Theme.of(context).primaryColor : Colors.white24,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: _finishQuiz,
                child: Text(
                  passed ? "Continue Journey" : "Retry Quiz",
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              if (passed)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Go Back", style: TextStyle(color: Colors.white54)),
                )
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final options = List<String>.from(question['options']);
    final correctIndex = question['correctIndex'] as int;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Question ${_currentIndex + 1} of ${_questions.length}",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(20),
              child: Text(
                question['question'],
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 30),
            ...List.generate(options.length, (index) {
              bool isSelected = _selectedOption == index;
              bool isCorrect = index == correctIndex;
              Color bgColor = Colors.white.withOpacity(0.05);
              Color borderColor = Colors.white24;

              if (_isAnswerChecked) {
                if (isCorrect) {
                  bgColor = Colors.green.withOpacity(0.3);
                  borderColor = Colors.greenAccent;
                } else if (isSelected && !isCorrect) {
                  bgColor = Colors.red.withOpacity(0.3);
                  borderColor = Colors.redAccent;
                }
              } else if (isSelected) {
                bgColor = Theme.of(context).primaryColor.withOpacity(0.3);
                borderColor = Theme.of(context).primaryColor;
              }

              return GestureDetector(
                onTap: () {
                  if (!_isAnswerChecked) {
                    setState(() {
                      _selectedOption = index;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: GoogleFonts.poppins(color: Colors.white54, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          options[index],
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                      if (_isAnswerChecked && isCorrect)
                        const Icon(Icons.check_circle_rounded, color: Colors.greenAccent)
                      else if (_isAnswerChecked && isSelected && !isCorrect)
                        const Icon(Icons.cancel_rounded, color: Colors.redAccent)
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            if (_isAnswerChecked) ...[
              GlassContainer(
                padding: const EdgeInsets.all(15),
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Explanation:", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 5),
                    Text(question['explanation'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ).animate().fade().slideY(begin: 0.2),
              const SizedBox(height: 20),
            ],
            SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedOption == null ? Colors.white12 : Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _selectedOption == null
                    ? null
                    : () {
                        if (_isAnswerChecked) {
                          _nextQuestion();
                        } else {
                          _checkAnswer();
                        }
                      },
                child: Text(
                  _isAnswerChecked ? "Next" : "Check Answer",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
