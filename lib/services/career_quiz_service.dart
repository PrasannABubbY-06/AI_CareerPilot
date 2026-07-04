import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import '../../models/career_quiz_result_model.dart';
import 'groq_service.dart';
import 'career_quiz_scoring_engine.dart';

class CareerQuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GroqService _groqService = GroqService();

  Future<CareerQuizResultModel?> getCachedResult() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('career_quiz')
          .doc('latest_result')
          .get();

      if (doc.exists && doc.data() != null) {
        return CareerQuizResultModel.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint("Error fetching cached quiz result: $e");
    }
    return null;
  }

  // Clear the cache manually when retaking quiz
  Future<void> clearQuizCache() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('career_quiz')
          .doc('latest_result')
          .delete();
    } catch (e) {
      debugPrint("Error clearing cache: $e");
    }
  }

  // Generate Hash
  String _generateAnswersHash(Map<String, String> answers) {
    final keys = answers.keys.toList()..sort();
    final combined = keys.map((k) => "$k=${answers[k]}").join('|');
    return sha256.convert(utf8.encode(combined)).toString();
  }

  Future<CareerQuizResultModel?> generateQuizResult(Map<String, String> qnaPairs) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final String currentHash = _generateAnswersHash(qnaPairs);

    // 1. Check Cache
    final cachedResult = await getCachedResult();
    if (cachedResult != null && cachedResult.answersHash == currentHash) {
      debugPrint("QUIZ CACHE HIT! Loading instantly.");
      return cachedResult; // Return without any AI call
    }
    debugPrint("QUIZ CACHE MISS or HASH CHANGED. Regenerating.");

    // 2. Local Deterministic Scoring
    final domainScores = CareerQuizScoringEngine.calculateScores(qnaPairs);
    final topDomain = CareerQuizScoringEngine.getTopDomain(domainScores);
    final secondaryDomain = CareerQuizScoringEngine.getSecondaryDomain(domainScores, topDomain);
    
    // Calculate a rough suitability % based on the difference between top and second
    final topScore = domainScores[topDomain] ?? 0;
    final totalPoints = domainScores.values.fold(0.0, (a, b) => a + b);
    
    int suitability = 75; // Baseline
    if (totalPoints > 0) {
      // If top score is dominant, high suitability
      double ratio = topScore / totalPoints;
      suitability = (ratio * 150).clamp(70, 98).toInt();
    }

    // 3. One AI Call for Personalization Context
    final String answersText = qnaPairs.entries.map((e) => "Q: ${e.key}\nA: ${e.value}").join('\n\n');

    final systemInstruction = """
    You are an elite Career Counselor. The user's primary domain has been locally calculated as: $topDomain.
    Analyze the user's specific answers to provide personalized guidance WITHIN the $topDomain domain.
    
    You MUST respond with ONLY a valid JSON object matching this structure EXACTLY:
    {
      "recommendedRoles": ["Specific Role 1", "Specific Role 2"],
      "strengths": ["Strength 1", "Strength 2", "Strength 3"],
      "weaknesses": ["Weakness 1", "Weakness 2", "Weakness 3"],
      "explanation": "A 3-sentence summary of why this fits their personality.",
      "learningRoadmap": ["Step 1", "Step 2", "Step 3", "Step 4"],
      "nextSkill": "Specific skill name"
    }
    Do not output markdown, code blocks, or extra text. Just the JSON object.
    """;

    try {
      final responseText = await _groqService.generateGenericResponse(answersText, systemInstruction);
      
      String cleanedJson = responseText.trim();
      final match = RegExp(r'\{[\s\S]*\}').firstMatch(cleanedJson);
      if (match != null) {
        cleanedJson = match.group(0)!;
      }

      final Map<String, dynamic> aiData = json.decode(cleanedJson);
      
      // 4. Combine Local + AI Data into the Final Model
      final result = CareerQuizResultModel(
        answersHash: currentHash,
        primaryDomain: topDomain,
        secondaryDomain: secondaryDomain,
        suitabilityPercentage: suitability,
        domainScores: domainScores,
        recommendedRoles: List<String>.from(aiData['recommendedRoles'] ?? []),
        strengths: List<String>.from(aiData['strengths'] ?? []),
        weaknesses: List<String>.from(aiData['weaknesses'] ?? []),
        explanation: aiData['explanation'] ?? '',
        learningRoadmap: List<String>.from(aiData['learningRoadmap'] ?? []),
        nextSkill: aiData['nextSkill'] ?? '',
        timestamp: DateTime.now(),
      );

      // 5. Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('career_quiz')
          .doc('latest_result')
          .set(result.toMap());

      return result;
    } catch (e) {
      debugPrint("Error generating quiz result: $e");
      return null;
    }
  }
}
