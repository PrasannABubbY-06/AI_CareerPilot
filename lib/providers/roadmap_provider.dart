import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/roadmap_service.dart';
import '../models/roadmap_model.dart';

final roadmapServiceProvider =
Provider<RoadmapService>((ref) {
  return RoadmapService();
});

final roadmapProvider =
StateNotifierProvider<
    RoadmapNotifier,
    AsyncValue<RoadmapModel?>
>((ref) {

  return RoadmapNotifier();
});

class RoadmapNotifier
    extends StateNotifier<AsyncValue<RoadmapModel?>> {

  RoadmapNotifier()
      : super(const AsyncData(null));

  void loadRoadmap(String skill) {

    try {

      state = const AsyncLoading();

      final data =
      RoadmapService.generateRoadmap(skill);

      state = AsyncData(data);

    } catch (e) {

      state = AsyncError(
        e,
        StackTrace.current,
      );
    }
  }
}