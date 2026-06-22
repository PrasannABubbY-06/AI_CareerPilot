import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  // =====================================================
  // 1. SAVE / UPDATE USER SCORE
  // =====================================================
  Future<void> saveUserScore({
    required int score,
    required String skill,
    required Map<String, double> radar,
  }) async {
    try {
      if (uid == null) return;

      final docRef =
          _firestore.collection("leaderboard").doc(uid);

      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          "uid": uid,
          "totalScore": score,
          "skills": {
            skill: score,
          },
          "radar": radar,
          "updatedAt": FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.update({
          "totalScore": FieldValue.increment(score),
          "skills.$skill": score,
          "radar": radar,
          "updatedAt": FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception("saveUserScore failed: $e");
    }
  }

  // =====================================================
  // 2. GET GLOBAL LEADERBOARD
  // =====================================================
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final snapshot = await _firestore
          .collection("leaderboard")
          .orderBy("totalScore", descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        return {
          "uid": doc["uid"],
          "totalScore": doc["totalScore"],
          "skills": doc["skills"],
          "radar": doc["radar"],
        };
      }).toList();
    } catch (e) {
      throw Exception("getLeaderboard failed: $e");
    }
  }

  // =====================================================
  // 3. GET USER RANK
  // =====================================================
  Future<int> getUserRank(String userId) async {
    try {
      final snapshot = await _firestore
          .collection("leaderboard")
          .orderBy("totalScore", descending: true)
          .get();

      final docs = snapshot.docs;

      for (int i = 0; i < docs.length; i++) {
        if (docs[i].id == userId) {
          return i + 1;
        }
      }

      return -1;
    } catch (e) {
      throw Exception("getUserRank failed: $e");
    }
  }
}

