import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/ai_service.dart';

// AI SERVICE PROVIDER
final aiServiceProvider =
    Provider<AIService>((ref) {

  return AIService();
});
