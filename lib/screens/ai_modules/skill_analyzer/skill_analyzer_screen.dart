import 'package:flutter/material.dart';

import 'skill_selection_screen.dart';
import 'career_goal_screen.dart';
import 'experience_screen.dart';
import 'ai_analysis_screen.dart';
import 'self_rating_screen.dart';
import 'question_screen.dart';
import 'result_screen.dart';

import 'models/question_model.dart';
import 'models/result_model.dart';
import 'services/skill_engine.dart';

class SkillAnalyzerScreen extends StatefulWidget {
  const SkillAnalyzerScreen({super.key});

  @override
  State<SkillAnalyzerScreen> createState() =>
      _SkillAnalyzerScreenState();
}

class _SkillAnalyzerScreenState
    extends State<SkillAnalyzerScreen> {
  final PageController controller =
      PageController();

  final SkillEngine engine =
      SkillEngine();

  String selectedSkill = "";
  String selectedGoal = "";
  String selectedExperience = "";

  Map<String, int> ratings = {};

  List<QuestionModel> questions = [];

  ResultModel? result;

  int currentQuestion = 0;

  int correct = 0;
  int beginnerCorrect = 0;
  int intermediateCorrect = 0;
  int advancedCorrect = 0;

  // ==========================
  // STEP 1
  // ==========================

  void saveSkill(String skill) {
    selectedSkill = skill;

    controller.nextPage(
      duration:
          const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ==========================
  // STEP 2
  // ==========================

  void saveGoal(String goal) {
    selectedGoal = goal;

    controller.nextPage(
      duration:
          const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ==========================
  // STEP 3
  // ==========================

  void saveExperience(
    String experience,
  ) {
    selectedExperience = experience;

    controller.nextPage(
      duration:
          const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ==========================
  // STEP 4
  // ==========================

  void analysisComplete() {
    controller.nextPage(
      duration:
          const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ==========================
  // STEP 5
  // ==========================

  void saveRatings(
    Map<String, int> values,
  ) {
    ratings = values;

    startAssessment();
  }

  // ==========================
  // LOAD QUESTIONS
  // ==========================

  void startAssessment() {
    try {
      questions = engine.loadQuestions(
        selectedSkill,
      );

      controller.nextPage(
        duration: const Duration(
          milliseconds: 300,
        ),
        curve: Curves.easeInOut,
      );

      setState(() {});
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) =>
            const AlertDialog(
          title: Text(
            "Skill Not Found",
          ),
          content: Text(
            "Questions unavailable",
          ),
        ),
      );
    }
  }

  // ==========================
  // ANSWER QUESTION
  // ==========================

  void answerQuestion(
    int selected,
  ) {
    final QuestionModel q =
        questions[currentQuestion];

    if (selected ==
        q.correctIndex) {
      correct++;

      if (q.level ==
          "beginner") {
        beginnerCorrect++;
      }

      if (q.level ==
          "intermediate") {
        intermediateCorrect++;
      }

      if (q.level ==
          "advanced") {
        advancedCorrect++;
      }
    }

    if (currentQuestion <
        questions.length - 1) {
      setState(() {
        currentQuestion++;
      });

      return;
    }

    generateResult();
  }

  // ==========================
  // GENERATE RESULT
  // ==========================

  void generateResult() {
    result = engine.calculateResult(
      skill:selectedSkill,
      questions: questions,
      correct: correct,
      
    );

    controller.nextPage(
      duration:
          const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    setState(() {});
  }

  // ==========================
  // RESTART
  // ==========================

  void restart() {
    selectedSkill = "";
    selectedGoal = "";
    selectedExperience = "";

    ratings = {};

    questions = [];

    currentQuestion = 0;

    correct = 0;
    beginnerCorrect = 0;
    intermediateCorrect = 0;
    advancedCorrect = 0;

    result = null;

    controller.jumpToPage(0);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xff0B1020),
      body: PageView(
        controller: controller,
        physics:
            const NeverScrollableScrollPhysics(),
        children: [
          SkillSelectionScreen(
            onNext: saveSkill,
          ),

          CareerGoalScreen(
            onNext: saveGoal,
          ),

          ExperienceScreen(
            onNext:
                saveExperience,
          ),

          AiAnalysisScreen(
            onComplete:
                analysisComplete,
          ),

          SelfRatingScreen(
            onSubmit:
                saveRatings,
          ),

          QuestionScreen(
            questions:
                questions,
            currentIndex:
                currentQuestion,
            onAnswer:
                answerQuestion,
          ),

          ResultScreen(
            result: result,
            onRestart:
                restart,
          ),
        ],
      ),
    );
  }
}
