import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../widgets/animations/three_d_tilt_wrapper.dart';
import '../../../services/career_quiz_service.dart';
import 'quiz_result_screen.dart';

class QuizQuestion {
  final String category;
  final String text;
  final List<String> options;

  QuizQuestion(this.category, this.text, this.options);
}

class QuizScreen extends StatefulWidget {
  final bool isRetake;
  const QuizScreen({super.key, this.isRetake = false});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final PageController _pageController = PageController();
  final CareerQuizService _quizService = CareerQuizService();
  int _currentIndex = 0;
  bool _isAnalyzing = false;
  bool _isLoadingCache = true;
  
  final Map<String, String> _answers = {};

  final List<QuizQuestion> _questions = [
    // 1. Interest Type
    QuizQuestion("Interest Type", "What type of tasks do you enjoy the most?", [
      "Building things and writing code",
      "Designing visuals and user experiences",
      "Managing projects and planning strategies",
      "Helping people and socializing"
    ]),
    // 2. Personality Type
    QuizQuestion("Personality Type", "How do you prefer to work?", [
      "Independently, deep focused work",
      "In a large group with lots of collaboration",
      "Directly interacting with clients or customers",
      "Organizing others and delegating tasks"
    ]),
    // 3. Work Style
    QuizQuestion("Work Style", "What is your ideal work environment?", [
      "Stable corporate environments",
      "High-risk, high-reward startups",
      "Secure public sector or government roles",
      "Remote freelancer with complete freedom"
    ]),
    // 4. Problem Solving
    QuizQuestion("Problem Solving", "How do you approach a complex problem?", [
      "Break it down into smaller, logical steps",
      "Collaborate and brainstorm with others",
      "Look for established rules and guidelines",
      "Use creativity and trial-and-error"
    ]),
    // 5. Data Handling
    QuizQuestion("Skill Strength", "How do you feel about working with large datasets?", [
      "I love it, data tells a story",
      "It's okay, I prefer qualitative research over numbers",
      "I hate working with spreadsheets",
      "I prefer managing the people who handle the data"
    ]),
    // 6. Education
    QuizQuestion("Academic Background", "What is your primary educational background?", [
      "Computer Science / IT",
      "Business / Management",
      "Arts / Design",
      "Science / Mathematics"
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _checkCache();
  }

  Future<void> _checkCache() async {
    if (widget.isRetake) {
      await _quizService.clearQuizCache();
      if (mounted) setState(() => _isLoadingCache = false);
      return;
    }

    final cachedResult = await _quizService.getCachedResult();
    if (cachedResult != null && mounted) {
      // Instant load
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(result: cachedResult),
        ),
      );
    } else if (mounted) {
      setState(() => _isLoadingCache = false);
    }
  }

  void _onOptionSelected(String option) async {
    final currentQ = _questions[_currentIndex];
    _answers[currentQ.text] = option;

    if (_currentIndex < _questions.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // Analyze
      setState(() {
        _isAnalyzing = true;
      });

      final result = await _quizService.generateQuizResult(_answers);
      
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });

        if (result != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QuizResultScreen(result: result),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to generate results. Please try again.")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCache) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator(color: Colors.purpleAccent)),
      );
    }

    if (_isAnalyzing) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.purpleAccent),
              ),
              const SizedBox(height: 24),
              Text(
                "Calculating domain scores...",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fade().slideY(),
              const SizedBox(height: 8),
              Text(
                "Our AI is building your personalized roadmap 🚀",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ).animate().fade(delay: 200.ms),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Career Quiz",
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
          // Background Glows
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.08),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          
          Column(
            children: [
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Question ${_currentIndex + 1} of ${_questions.length}",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / _questions.length,
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Disable manual swipe
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final q = _questions[index];
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.purpleAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              q.category.toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: Colors.purpleAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ).animate().fade().slideY(begin: 0.2),
                          
                          const SizedBox(height: 24),
                          
                          Text(
                            q.text,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ).animate().fade(delay: 100.ms).scale(begin: const Offset(0.95, 0.95)),
                          
                          const SizedBox(height: 48),
                          
                          ...q.options.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final optionText = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ThreeDTiltWrapper(
                                child: InkWell(
                                  onTap: () => _onOptionSelected(optionText),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.black26,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white24),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            String.fromCharCode(65 + idx), // A, B, C, D
                                            style: GoogleFonts.poppins(
                                              color: Colors.white70,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            optionText,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ).animate().fade(delay: (200 + idx * 100).ms).slideX(begin: 0.1);
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
