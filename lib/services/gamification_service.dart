import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gamification_model.dart';
import '../models/achievement_model.dart';
import 'notification_service.dart';
import 'dart:async';

class GamificationService extends ChangeNotifier {
  static const String _cacheKey = 'gamification_data';
  GamificationModel _data = GamificationModel();
  
  final StreamController<AchievementModel> _achievementController = StreamController<AchievementModel>.broadcast();
  Stream<AchievementModel> get achievementStream => _achievementController.stream;

  GamificationModel get data => _data;

  // Constants for balancing
  static const int xpPerTask = 50;
  static const int coinsPerTask = 10;
  static const int xpToNextLevelBase = 100; // Level * 100 to level up (e.g., Level 1 -> 2 needs 100 XP)

  // Singleton pattern
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  
  GamificationService._internal() {
    _loadLocalData();
  }

  /// Calculates XP required for the next level
  int get xpForNextLevel => _data.level * xpToNextLevelBase;

  /// Gets progress percentage to next level (0.0 to 1.0)
  double get levelProgress => _data.xp / xpForNextLevel;

  Future<void> _loadLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_cacheKey);
      final user = FirebaseAuth.instance.currentUser;
      
      if (jsonStr != null) {
        _data = GamificationModel.fromJson(jsonStr);
      }
      
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('gamification').doc('data').set(_data.toMap());
      }
      
      _checkAchievements();
      notifyListeners();
      
      // Async sync from Firebase if logged in
      _syncFromFirebase();
    } catch (e) {
      debugPrint("Gamification Load Error: $e");
    }
  }

  Future<void> _saveLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, _data.toJson());
      notifyListeners();
    } catch (e) {
      debugPrint("Gamification Save Error: $e");
    }
  }

  Future<void> _syncFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('gamification')
          .doc('progress')
          .get();

      if (doc.exists && doc.data() != null) {
        _data = GamificationModel.fromMap(doc.data()!);
        _updateStreak();
        _saveLocalData();
      }
    } catch (e) {
      debugPrint("Gamification Sync Error: $e");
    }
  }

  Future<void> _syncToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('gamification')
          .doc('progress')
          .set(_data.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint("Gamification SyncToFirebase Error: $e");
    }
  }

  void _updateStreak() {
    final now = DateTime.now();
    final lastActive = _data.lastActiveDate;

    if (lastActive == null) {
      _data = _data.copyWith(streakDays: 1, lastActiveDate: now);
      return;
    }

    final difference = DateTime(now.year, now.month, now.day)
        .difference(DateTime(lastActive.year, lastActive.month, lastActive.day))
        .inDays;

    if (difference == 1) {
      // Consecutive day
      _data = _data.copyWith(
        streakDays: _data.streakDays + 1, 
        lastActiveDate: now,
        yesterdayXp: _data.todayXp,
        yesterdayTasks: _data.todayTasks,
        todayXp: 0,
        todayTasks: const [],
      );
    } else if (difference > 1) {
      // Missed a day, streak reset
      _data = _data.copyWith(
        streakDays: 1, 
        lastActiveDate: now,
        yesterdayXp: 0, // missed more than 1 day, so yesterday was 0
        yesterdayTasks: const [],
        todayXp: 0,
        todayTasks: const [],
      );
    } else {
      // Same day, just update lastActiveDate
      _data = _data.copyWith(lastActiveDate: now);
    }
    
    // Check achievements
    _checkAchievements();
  }

  /// Check and unlock achievements
  void _checkAchievements() {
    if (_data.completedTasks.isNotEmpty) {
      unlockAchievement("first_task");
    }
    if (_data.completedTasks.length >= 10) {
      unlockAchievement("skill_collector");
    }
    if (_data.streakDays >= 7) {
      unlockAchievement("streak_7");
    }
    if (_data.streakDays >= 30) {
      unlockAchievement("streak_30");
    }
    if (_data.level >= 75) {
      unlockAchievement("job_ready");
    }
  }

  Future<void> unlockAchievement(String achievementId) async {
    if (_data.achievements.contains(achievementId)) return;

    final updatedAchievements = List<String>.from(_data.achievements)..add(achievementId);
    
    // Find achievement to give reward
    final achievement = AchievementModel.allAchievements.firstWhere(
      (a) => a.id == achievementId, 
      orElse: () => AchievementModel(id: '', title: '', description: '', icon: Icons.star, xpReward: 0, color: Colors.white)
    );

    int newXp = _data.xp;
    if (achievement.id.isNotEmpty) {
      newXp += achievement.xpReward;
      
      // Notify user via NotificationService
      NotificationService().sendNotification(
        title: "Achievement Unlocked! 🏆",
        message: "You unlocked '${achievement.title}' and earned ${achievement.xpReward} XP!",
        category: NotificationCategory.goalProgress,
      );
      
      // Emit to stream for UI popup
      _achievementController.add(achievement);
    }

    _data = _data.copyWith(achievements: updatedAchievements, xp: newXp);
    
    // Just force save
    await _saveLocalData();
    _syncToFirebase();
  }

  /// Call this when a task is checked off in the roadmap
  Future<bool> completeTask(String taskId) async {
    if (_data.completedTasks.contains(taskId)) return false; // Already completed

    // 1. Calculate new stats
    int newXp = _data.xp + xpPerTask;
    int newCoins = _data.coins + coinsPerTask;
    int newLevel = _data.level;
    
    bool leveledUp = false;

    // Check for level up
    while (newXp >= (newLevel * xpToNextLevelBase)) {
      newXp -= (newLevel * xpToNextLevelBase);
      newLevel++;
      leveledUp = true;
    }

    // 2. Update model
    final updatedTasks = List<String>.from(_data.completedTasks)..add(taskId);
    final updatedTodayTasks = List<String>.from(_data.todayTasks)..add(taskId);

    _data = _data.copyWith(
      xp: newXp,
      level: newLevel,
      coins: newCoins,
      completedTasks: updatedTasks,
      todayXp: _data.todayXp + xpPerTask,
      todayTasks: updatedTodayTasks,
    );

    _updateStreak(); // Update streak & check achievements

    // 3. Save
    await _saveLocalData();
    _syncToFirebase(); // Fire and forget background sync

    return leveledUp;
  }

  /// Remove task completion (if user unchecks)
  Future<void> uncompleteTask(String taskId) async {
    if (!_data.completedTasks.contains(taskId)) return;

    final updatedTasks = List<String>.from(_data.completedTasks)..remove(taskId);
    final updatedTodayTasks = List<String>.from(_data.todayTasks)..remove(taskId);
    
    // Deduct penalties (we don't de-level to keep it friendly, just deduct XP)
    int newXp = _data.xp - xpPerTask;
    if (newXp < 0) newXp = 0;
    
    int newCoins = _data.coins - coinsPerTask;
    if (newCoins < 0) newCoins = 0;

    int newTodayXp = _data.todayXp - xpPerTask;
    if (newTodayXp < 0) newTodayXp = 0;

    _data = _data.copyWith(
      xp: newXp,
      coins: newCoins,
      completedTasks: updatedTasks,
      todayXp: newTodayXp,
      todayTasks: updatedTodayTasks,
    );

    await _saveLocalData();
    _syncToFirebase();
  }

  bool isTaskCompleted(String taskId) {
    return _data.completedTasks.contains(taskId);
  }

  /// Set the active roadmap to pull daily missions from
  Future<void> setActiveRoadmapSkill(String skill) async {
    if (_data.activeRoadmapSkill != skill) {
      _data = _data.copyWith(activeRoadmapSkill: skill);
      await _saveLocalData();
      _syncToFirebase();
    }
  }
}
