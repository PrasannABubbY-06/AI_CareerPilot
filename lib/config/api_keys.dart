import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeys {
  static String get groqApiKey {
    const compileTimeKey = String.fromEnvironment('GROQ_API_KEY');
    if (compileTimeKey.isNotEmpty) {
      final key = compileTimeKey.trim();
      debugPrint("API_KEYS: Loaded GROQ_API_KEY from String.fromEnvironment. Length: ${key.length}. Masked: ${key.substring(0, 10)}...${key.substring(key.length - 4)}");
      return key;
    }
    
    final envKey = dotenv.env['GROQ_API_KEY']?.trim() ?? '';
    if (envKey.isNotEmpty) {
      debugPrint("API_KEYS: Loaded GROQ_API_KEY from dotenv. Length: ${envKey.length}. Masked: ${envKey.substring(0, 10)}...${envKey.substring(envKey.length - 4)}");
      return envKey;
    }

    debugPrint("API_KEYS: GROQ_API_KEY not found in String.fromEnvironment or dotenv!");
    return '';
  }

  static String get geminiApiKey {
    const compileTimeKey = String.fromEnvironment('GEMINI_API_KEY');
    if (compileTimeKey.isNotEmpty) {
      final key = compileTimeKey.trim();
      debugPrint("API_KEYS: Loaded GEMINI_API_KEY from String.fromEnvironment. Length: ${key.length}. Masked: ${key.substring(0, min(10, key.length))}...${key.substring(max(0, key.length - 4))}");
      return key;
    }
    
    final envKey = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
    if (envKey.isNotEmpty) {
      debugPrint("API_KEYS: Loaded GEMINI_API_KEY from dotenv. Length: ${envKey.length}. Masked: ${envKey.substring(0, min(10, envKey.length))}...${envKey.substring(max(0, envKey.length - 4))}");
      return envKey;
    }

    debugPrint("API_KEYS: GEMINI_API_KEY not found in String.fromEnvironment or dotenv!");
    return '';
  }

  static int min(int a, int b) => a < b ? a : b;
  static int max(int a, int b) => a > b ? a : b;
}
