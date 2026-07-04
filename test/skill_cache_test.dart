import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_careerpilot/services/skill_cache_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Skill Knowledge Base & Caching System Tests', () {
    setUp(() {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    test('Pre-populated roadmap lookup (Cache Hit)', () async {
      final flutterRoadmap = await SkillCacheManager.getRoadmap("Flutter");
      expect(flutterRoadmap, isNotNull);
      expect(flutterRoadmap, contains("Flutter Roadmap"));
      expect(flutterRoadmap, contains("https://www.youtube.com/watch?v=VPvVD8t02U8"));

      final devopsRoadmap = await SkillCacheManager.getRoadmap("DevOps");
      expect(devopsRoadmap, isNotNull);
      expect(devopsRoadmap, contains("DevOps Roadmap"));
    });

    test('Missing skill lookup (Cache Miss)', () async {
      final newSkill = await SkillCacheManager.getRoadmap("CyberSecurityAndCloudSecurity");
      expect(newSkill, isNull);
    });

    test('Save & Load new skill (Auto Save & Auto Reuse)', () async {
      const skillName = "CyberSecurityAndCloudSecurity";
      const roadmapText = "### 🗺️ CyberSecurityAndCloudSecurity Roadmap:\n- **Step 1**: Learn networking basics.\n- **Step 2**: Study firewalls.";

      // Verify Cache Miss initially
      final initialLookup = await SkillCacheManager.getRoadmap(skillName);
      expect(initialLookup, isNull);

      // Save to Cache
      await SkillCacheManager.saveRoadmap(skillName, roadmapText);

      // Verify Cache Hit on subsequent retrieval (Auto Reuse)
      final afterSaveLookup = await SkillCacheManager.getRoadmap(skillName);
      expect(afterSaveLookup, equals(roadmapText));
    });

    test('Case insensitivity and trimming of skill names', () async {
      final roadmap1 = await SkillCacheManager.getRoadmap("  FLuTTeR  ");
      expect(roadmap1, isNotNull);
      expect(roadmap1, contains("Flutter Roadmap"));
    });
  });
}
