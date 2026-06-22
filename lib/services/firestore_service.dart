import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      } else {
        await userRef.update({
          "lastLogin": FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception("saveUserAfterLogin failed: $e");
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
    } catch (e) {
      throw Exception("saveUserProfile failed: $e");
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
      throw Exception("getUser failed: $e");
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
    } catch (e) {
      throw Exception("saveResumeReport failed: $e");
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
      throw Exception("saveSkillResult failed: $e");
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
      throw Exception("saveCareerAnalysis failed: $e");
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
    } catch (e) {
      throw Exception("saveRoadmap failed: $e");
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
    } catch (e) {
      throw Exception("saveMockInterview failed: $e");
    }
  }
}