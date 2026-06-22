import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/ai_modules/resume_reviewer_screen.dart';
import '../screens/ai_modules/mock_interview_screen.dart';
import '../screens/ai_modules/roadmap_screen.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String careerAnalyzer = '/career-analyzer';
  static const String resumeReview = '/resume-review';
  static const String mockInterview = '/mock-interview';
  static const String roadmap = '/roadmap';

  static Map<String, WidgetBuilder> routes = {
    dashboard: (context) => DashboardScreen(),
    login: (context) => const LoginScreen(),
    profile: (context) => const ProfileScreen(),
    resumeReview: (context) => const ResumeReviewerScreen(),
    mockInterview: (context) => const MockInterviewScreen(),
    roadmap: (context) => const RoadmapScreen(),
  };
}