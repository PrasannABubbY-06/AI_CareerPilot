import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/resource_pack_model.dart';
import 'groq_service.dart';

class ResourceLibraryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GroqService _groqService = GroqService();

  Future<ResourcePackModel?> getResourcePack(String skillName) async {
    final docId = skillName.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-z0-9_]'), '');

    try {
      // 1. Check cache
      final doc = await _firestore.collection('skill_resources').doc(docId).get();
      if (doc.exists && doc.data() != null) {
        return ResourcePackModel.fromMap(doc.data()!);
      }

      // 2. Generate with AI
      final systemInstruction = """
      You are an expert technical curriculum designer.
      Generate a comprehensive resource pack for learning: $skillName.
      
      You MUST respond with ONLY a valid JSON object matching this structure EXACTLY. No markdown formatting outside the JSON, no extra text.
      {
        "skillName": "$skillName",
        "youtubeVideos": [
          {"title": "Video Title", "url": "https://youtube.com/..."}
        ],
        "officialDocs": [
          {"title": "Doc Title", "url": "https://..."}
        ],
        "freeWebsites": [
          {"title": "Website Title", "url": "https://..."}
        ],
        "practicePlatforms": [
          {"title": "Platform Title", "url": "https://..."}
        ],
        "githubRepos": [
          {"title": "Repo Title", "url": "https://github.com/..."}
        ],
        "miniProjects": [
          {"title": "Project Idea", "url": "Concept or link"}
        ]
      }
      Provide 2-3 high quality, real links per category. Do not hallucinate fake links; use established platforms (MDN, W3Schools, freeCodeCamp, etc).
      """;

      final responseText = await _groqService.generateGenericResponse(
        "Generate learning resources for $skillName", 
        systemInstruction,
      );

      // Clean JSON
      String cleanedJson = responseText.trim();
      if (cleanedJson.startsWith("```json")) {
        cleanedJson = cleanedJson.replaceAll("```json", "");
        cleanedJson = cleanedJson.replaceAll("```", "");
        cleanedJson = cleanedJson.trim();
      } else if (cleanedJson.startsWith("```")) {
        cleanedJson = cleanedJson.replaceAll("```", "").trim();
      }

      final Map<String, dynamic> data = json.decode(cleanedJson);
      final result = ResourcePackModel.fromMap(data);

      // 3. Cache it
      await _firestore.collection('skill_resources').doc(docId).set(result.toMap());

      return result;
    } catch (e) {
      debugPrint("Error fetching/generating resource pack for $skillName: $e");
      return null;
    }
  }
}
