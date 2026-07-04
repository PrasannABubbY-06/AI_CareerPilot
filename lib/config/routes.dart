import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/ai_modules/resume_reviewer_screen.dart';
import '../screens/ai_modules/mock_interview_screen.dart';
import '../screens/ai_modules/roadmap_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/ai_modules/career_mentor/mentor_input_screen.dart';
import '../screens/ai_modules/career_mentor/mentor_report_screen.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String careerAnalyzer = '/career-analyzer';
  static const String careerMentor = '/career-mentor';
  static const String careerMentorReport = '/career-mentor-report';
  static const String resumeReview = '/resume-review';
  static const String mockInterview = '/mock-interview';
  static const String roadmap = '/roadmap';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> routes = {
    dashboard: (context) => DashboardScreen(),
    login: (context) => const LoginScreen(),
    profile: (context) => const ProfileScreen(),
    resumeReview: (context) => const ResumeReviewerScreen(),
    mockInterview: (context) => const MockInterviewScreen(),
    roadmap: (context) => const RoadmapScreen(),
    notifications: (context) => const NotificationsScreen(),
    careerMentor: (context) => const MentorInputScreen(),
    careerMentorReport: (context) {
      final report = ModalRoute.of(context)!.settings.arguments as String? ?? "No report provided.";
      return MentorReportScreen(reportMarkdown: report);
    },
  };
}