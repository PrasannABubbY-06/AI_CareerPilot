import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceInterviewService {
  final SpeechToText speech = SpeechToText();
  final FlutterTts tts = FlutterTts();

  bool isReady = false;

  Future<void> init() async {
    isReady = await speech.initialize();
  }

  Future<void> speak(String text) async {
    await tts.speak(text);
  }

  Future<String> listen() async {
    if (!isReady) return "";

    String result = "";

    await speech.listen(
      onResult: (val) {
        result = val.recognizedWords;
      },
    );

    await Future.delayed(const Duration(seconds: 5));
    await speech.stop();

    return result;
  }
}