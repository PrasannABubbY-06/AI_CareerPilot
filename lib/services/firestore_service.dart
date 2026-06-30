import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =====================================================
  // CURRENT USER ID (SAFE)
  // =====================================================
  String? get uid => _auth.currentUser?.uid;

  // =====================================================
  // SAVE OR UPDATE USER AFTER LOGIN
  // =====================================================
  Future<void> saveUserAfterLogin(User user) async {
    try {
      final userRef = _firestore.collection("users").doc(user.uid);

      final doc = await userRef.get();

      if (!doc.exists) {
        await userRef.set({
          "uid": user.uid,
          "name": user.displayName ?? "No Name",
          "email": user.email ?? "",
          "createdAt": FieldValue.serverTimestamp(),
        });
        await NotificationService().sendNotification(
          title: "Welcome to AI_CareerPilot!",
          message: "Your premium career journey starts now.",
          category: NotificationCategory.systemUpdate,
        );
      } else {
        await userRef.update({
          "lastLogin": FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("saveUserAfterLogin failed: $e");
    }
  }

  // =====================================================
  // SAVE USER PROFILE (MANUAL UPDATE)
  // =====================================================
  Future<void> saveUserProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      await _firestore.collection("users").doc(uid).set({
        "name": name,
        "email": email,
        "phone": phone,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      await NotificationService().sendNotification(
        title: "Profile Updated",
        message: "Your profile details have been saved successfully.",
        category: NotificationCategory.systemUpdate,
      );
    } catch (e) {
      debugPrint("saveUserProfile failed: $e");
    }
  }

  // =====================================================
  // GET USER DATA
  // =====================================================
  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final doc =
          await _firestore.collection("users").doc(userId).get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint("getUser failed: $e");
      return null;
    }
  }

  // =====================================================
  // SAVE RESUME REPORT
  // =====================================================
  Future<void> saveResumeReport({
    required int atsScore,
    required List<String> skills,
    required List<String> suggestions,
  }) async {
    try {
      await _firestore.collection("resume_reports").add({
        "userId": uid,
        "atsScore": atsScore,
        "skills": skills,
        "suggestions": suggestions,
        "createdAt": FieldValue.serverTimestamp(),
      });
      
      await NotificationService().sendNotification(
        title: "Resume Analysis Completed",
        message: "Your ATS Score is $atsScore%. Check the profile for detailed insights.",
        category: NotificationCategory.resumeInsight,
      );
    } catch (e) {
      debugPrint("saveResumeReport failed: $e");
    }
  }


  // =====================================================
  // SAVE SKILL ANALYZER RESULT (ADD THIS)
  // =====================================================
  Future<void> saveSkillResult({
    required String skill,
    required double score,
    required Map<String, double> radar,
  }) async {
    try {
      await _firestore.collection("skill_results").add({
        "userId": uid,
        "skill": skill,
        "score": score,
        "radar": radar,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("saveSkillResult failed: $e");
    }
  }

  // =====================================================
  // SAVE CAREER ANALYSIS
  // =====================================================
  Future<void> saveCareerAnalysis({
    required int score,
    required List<String> strengths,
    required List<String> weaknesses,
    required List<String> recommendations,
  }) async {
    try {
      await _firestore.collection("career_analysis").add({
        "userId": uid,
        "score": score,
        "strengths": strengths,
        "weaknesses": weaknesses,
        "recommendations": recommendations,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("saveCareerAnalysis failed: $e");
    }
  }

  // =====================================================
  // SAVE ROADMAP
  // =====================================================
  Future<void> saveRoadmap({
    required String role,
    required List<String> roadmap,
  }) async {
    try {
      await _firestore.collection("roadmaps").add({
        "userId": uid,
        "role": role,
        "roadmap": roadmap,
        "createdAt": FieldValue.serverTimestamp(),
      });
      
      await NotificationService().sendNotification(
        title: "New Learning Path Generated",
        message: "Your roadmap for $role is ready.",
        category: NotificationCategory.learningReminder,
      );
    } catch (e) {
      debugPrint("saveRoadmap failed: $e");
    }
  }

  // =====================================================
  // SAVE MOCK INTERVIEW
  // =====================================================
  Future<void> saveMockInterview({
    required int score,
    required List<String> questions,
    required List<String> feedback,
  }) async {
    try {
      await _firestore.collection("mock_interviews").add({
        "userId": uid,
        "score": score,
        "questions": questions,
        "feedback": feedback,
        "createdAt": FieldValue.serverTimestamp(),
      });
      
      await NotificationService().sendNotification(
        title: "Mock Interview Completed",
        message: "You scored $score/10. Review your feedback to improve.",
        category: NotificationCategory.interviewPrep,
      );
    } catch (e) {
      debugPrint("saveMockInterview failed: $e");
    }
  }
}