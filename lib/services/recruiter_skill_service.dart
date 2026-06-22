import 'package:cloud_firestore/cloud_firestore.dart';

class RecruiterSkillService {

  Future<List<Map<String, dynamic>>> getTopCandidates(String skill) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("skill_results")
        .orderBy("score", descending: true)
        .get();

    return snapshot.docs
        .map((e) => e.data())
        .toList();
  }
}