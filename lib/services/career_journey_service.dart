import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/skill_journey_model.dart';
import 'gamification_service.dart';

class CareerJourneyService extends ChangeNotifier {
  static const String _activeSkillKey = 'active_skill_journey';
  static const String _historyKey = 'skill_journey_history';

  SkillJourneyModel? _activeSkill;
  List<JourneyHistoryModel> _history = [];

  SkillJourneyModel? get activeSkill => _activeSkill;
  List<JourneyHistoryModel> get history => _history;

  static final CareerJourneyService _instance = CareerJourneyService._internal();
  factory CareerJourneyService() => _instance;

  CareerJourneyService._internal() {
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final String? activeJson = prefs.getString(_activeSkillKey);
      if (activeJson != null) {
        _activeSkill = SkillJourneyModel.fromJson(activeJson);
      }

      final List<String>? historyJson = prefs.getStringList(_historyKey);
      if (historyJson != null) {
        _history = historyJson.map((e) => JourneyHistoryModel.fromMap(json.decode(e))).toList();
      }

      notifyListeners();
      _syncFromFirebase();
    } catch (e) {
      debugPrint("Journey Load Error: $e");
    }
  }

  Future<void> _saveLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_activeSkill != null) {
        await prefs.setString(_activeSkillKey, _activeSkill!.toJson());
      } else {
        await prefs.remove(_activeSkillKey);
      }

      final historyList = _history.map((e) => json.encode(e.toMap())).toList();
      await prefs.setStringList(_historyKey, historyList);
      
      notifyListeners();
    } catch (e) {
      debugPrint("Journey Save Error: $e");
    }
  }

  Future<void> _syncFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('career_journey')
          .doc('progress')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['activeSkill'] != null) {
          _activeSkill = SkillJourneyModel.fromMap(data['activeSkill']);
        }
        
        if (data['history'] != null) {
          final List<dynamic> histList = data['history'];
          _history = histList.map((e) => JourneyHistoryModel.fromMap(e)).toList();
        }
        _saveLocalData();
      }
    } catch (e) {
      debugPrint("Journey Sync Error: $e");
    }
  }

  Future<void> _syncToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('career_journey')
          .doc('progress')
          .set({
        'activeSkill': _activeSkill?.toMap(),
        'history': _history.map((e) => e.toMap()).toList(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Journey SyncToFirebase Error: $e");
    }
  }

  Future<void> startNewSkill(String skillName) async {
    if (_activeSkill != null && _activeSkill!.skillName != skillName) {
      // Move current to history
      _moveToHistory();
    }

    _activeSkill = SkillJourneyModel(
      skillName: skillName,
      lastActiveDate: DateTime.now(),
    );

    await _saveLocalData();
    _syncToFirebase();
  }

  void _moveToHistory() {
    if (_activeSkill == null) return;

    final historyItem = JourneyHistoryModel(
      skillName: _activeSkill!.skillName,
      finalLevelIndex: _activeSkill!.currentLevelIndex,
      completionPercentage: _activeSkill!.progressPercentage,
      startDate: DateTime.now().subtract(const Duration(days: 7)), // Dummy start date approximation
      endDate: DateTime.now(),
    );

    _history.add(historyItem);
  }

  Future<void> completeStageAndUnlockNext() async {
    if (_activeSkill == null) return;

    int nextLevel = _activeSkill!.currentLevelIndex + 1;
    double newProgress = (nextLevel / 4.0) * 100.0; // 5 stages (0 to 4). So 4 is 100%

    String newStatus = "active";
    if (nextLevel > 4) {
      nextLevel = 4;
      newProgress = 100.0;
      newStatus = "completed";
      
      // Auto move to history if fully completed
      Future.delayed(const Duration(seconds: 2), () {
        _moveToHistory();
        _activeSkill = null;
        _saveLocalData();
        _syncToFirebase();
      });
    }

    _activeSkill = _activeSkill!.copyWith(
      currentLevelIndex: nextLevel,
      progressPercentage: newProgress,
      status: newStatus,
      lastActiveDate: DateTime.now(),
    );

    // Give Gamification XP
    GamificationService().completeTask("journey_\${_activeSkill!.skillName}_lvl\$nextLevel");

    await _saveLocalData();
    _syncToFirebase();
  }

  Future<void> deleteFromHistory(String skillName) async {
    _history.removeWhere((item) => item.skillName == skillName);
    await _saveLocalData();
    _syncToFirebase();
  }

  Future<void> updateLastActive() async {
    if (_activeSkill == null) return;
    _activeSkill = _activeSkill!.copyWith(lastActiveDate: DateTime.now());
    await _saveLocalData();
    // Intentionally omit firebase sync for minor active date ping unless needed
  }
}
