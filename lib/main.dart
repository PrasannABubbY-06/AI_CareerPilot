import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'config/app_theme.dart';
import 'services/theme_service.dart';
import 'package:provider/provider.dart';
import 'services/career_journey_service.dart';

// SCREENS
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/ai_modules/resume_reviewer_screen.dart';
import 'screens/ai_modules/mock_interview_screen.dart';
import 'screens/ai_modules/roadmap_screen.dart';
import 'screens/ai_modules/jd_match_screen.dart';
import 'screens/ai_modules/resume_builder_screen.dart';
import 'screens/ai_modules/voice_interview/voice_interview_screen.dart';
import 'screens/ai_modules/skill_analyzer/skill_analyzer_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/recruiter/recruiter_dashboard.dart';
import 'screens/goals/weekly_goals_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/ai_modules/career_mentor/mentor_input_screen.dart';
import 'screens/ai_modules/career_mentor/mentor_report_screen.dart';
import 'screens/ai_modules/career_quiz/quiz_screen.dart';
import 'screens/ai_modules/career_twin/career_journey_screen.dart';
import 'screens/ai_modules/career_twin/weekly_report_screen.dart';
import 'screens/ai_modules/skill_analyzer/skill_resource_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: ".env");


  // ✅ SAFE FIREBASE INIT
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("🔥 Firebase init error: $e");
  }

  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding =
      prefs.getBool("onboarding_completed") ?? false;

  await ThemeService().initialize();

  runApp(MyApp(seenOnboarding: seenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;

  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService(),
      builder: (context, themeMode, _) {
        return ChangeNotifierProvider(
          create: (_) => CareerJourneyService(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
          title: "AI_CareerPilot",

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,

          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // logged in
              if (snapshot.hasData) {
                return DashboardScreen();
              }

              // not logged in
              if (seenOnboarding) {
                return const LoginScreen();
              }

              return const OnboardingScreen();
            },
          ),

          routes: {
            "/login": (_) => const LoginScreen(),
            "/register": (context) => const RegisterScreen(),
            "/dashboard": (_) => DashboardScreen(),
            "/skill-analyzer": (_) => const SkillAnalyzerScreen(),
            "/resume-review": (_) => ResumeReviewerScreen(),
            "/resume-builder": (_) => const ResumeBuilderScreen(),
            "/jd-match": (_) => const JDMatchScreen(),
            "/mock-interview": (_) => const MockInterviewScreen(),
            "/voice-interview": (_) => const VoiceInterviewScreen(),
            "/roadmap": (_) => const RoadmapScreen(),
            "/profile": (_) => const ProfileScreen(),
            "/recruiter-dashboard": (_) => const RecruiterDashboard(),
            "/weekly-goals": (context) => const WeeklyGoalsScreen(),
            "/notifications": (context) => const NotificationsScreen(),
            "/career-mentor": (context) => const MentorInputScreen(),
            "/career-mentor-report": (context) {
              final report = ModalRoute.of(context)!.settings.arguments as String? ?? "No report provided.";
              return MentorReportScreen(reportMarkdown: report);
            },
            "/career-quiz": (context) => const QuizScreen(),
            "/career-journey": (context) => const CareerJourneyScreen(),
            "/weekly-report": (context) => const WeeklyReportScreen(),
            "/skill-resources": (context) {
              final skillName = ModalRoute.of(context)!.settings.arguments as String? ?? "Unknown Skill";
              return SkillResourceScreen(skillName: skillName);
            },
          },
          ),
        );
      },
    );
  }
}
