import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'gamification_service.dart';
import 'notification_service.dart';
import 'groq_service.dart';
import 'career_journey_service.dart';

class SmartNotificationEngine {
  static final SmartNotificationEngine _instance = SmartNotificationEngine._internal();
  factory SmartNotificationEngine() => _instance;
  SmartNotificationEngine._internal();

  final GamificationService _gamification = GamificationService();
  final NotificationService _notifications = NotificationService();
  final GroqService _groq = GroqService();

  Future<void> runStartupChecks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckStr = prefs.getString('last_notification_check');
      final now = DateTime.now();

      if (lastCheckStr != null) {
        final lastCheck = DateTime.parse(lastCheckStr);
        // Only run checks once per day to avoid spam
        if (now.difference(lastCheck).inHours < 12) {
          return;
        }
      }

      await _evaluateStreak(now);
      await _evaluateWeeklyReport(now, prefs);
      await _evaluateDailyMotivation(now);
      await _evaluateJourneyInactivity(now);

      await prefs.setString('last_notification_check', now.toIso8601String());
    } catch (e) {
      debugPrint("SmartNotificationEngine Error: $e");
    }
  }

  Future<void> _evaluateStreak(DateTime now) async {
    final lastActive = _gamification.data.lastActiveDate;
    if (lastActive == null) return;

    final diff = now.difference(lastActive).inHours;
    
    // If it's been more than 24 hours, they are in danger of losing their streak
    if (diff >= 24 && diff < 48) {
      await _notifications.sendNotification(
        title: "Streak Warning! ⚠️",
        message: "You haven't completed any tasks today. Don't lose your ${_gamification.data.streakDays}-day streak!",
        category: NotificationCategory.learningReminder,
      );
    }
  }

  Future<void> _evaluateJourneyInactivity(DateTime now) async {
    final journeyService = CareerJourneyService();
    final activeSkill = journeyService.activeSkill;
    if (activeSkill == null) return;

    final diff = now.difference(activeSkill.lastActiveDate).inHours;
    if (diff >= 7 && diff < 24) {
      final stageNames = ["Beginner", "Intermediate", "Advanced", "Expert", "Job Ready"];
      final stage = stageNames[activeSkill.currentLevelIndex];
      await _notifications.sendNotification(
        title: "Journey Paused ⏸️",
        message: "Your Career Journey is paused at ${activeSkill.skillName} - $stage. Continue to reach the next level 🚀",
        category: NotificationCategory.learningReminder,
      );
    }
  }

  Future<void> _evaluateWeeklyReport(DateTime now, SharedPreferences prefs) async {
    final lastReportStr = prefs.getString('last_weekly_report_prompt');
    bool shouldPrompt = false;

    if (lastReportStr == null) {
      shouldPrompt = true;
    } else {
      final lastReport = DateTime.parse(lastReportStr);
      if (now.difference(lastReport).inDays >= 7) {
        shouldPrompt = true;
      }
    }

    if (shouldPrompt && _gamification.data.completedTasks.isNotEmpty) {
      await _notifications.sendNotification(
        title: "Weekly Report Ready 📊",
        message: "Your AI Career Twin has a new weekly performance summary ready for you.",
        category: NotificationCategory.systemUpdate,
      );
      await prefs.setString('last_weekly_report_prompt', now.toIso8601String());
    }
  }

  Future<void> _evaluateDailyMotivation(DateTime now) async {
    // Generate a quick AI motivation based on progress
    final goal = _gamification.data.careerGoal;
    if (goal == null || goal.isEmpty) return;

    final title = "Daily AI Advice 💡";
    final message = await _groq.generateDailyMotivation(
      "User", 
      _gamification.data.level, 
      _gamification.data.streakDays,
      goal
    );

    // Keep it short for the notification
    String shortMessage = message.replaceAll('*', '');
    if (shortMessage.length > 100) {
      shortMessage = "${shortMessage.substring(0, 97)}...";
    }

    await _notifications.sendNotification(
      title: title,
      message: shortMessage,
      category: NotificationCategory.careerUpdate,
    );
  }
}
