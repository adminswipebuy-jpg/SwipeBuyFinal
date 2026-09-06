import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceAssistantService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _available = false;

  Future<bool> initialize({required void Function(String status) onStatus}) async {
    _available = await _speech.initialize(onStatus: onStatus);
    return _available;
  }

  bool get isListening => _speech.isListening;

  Future<void> listen({required void Function(SpeechRecognitionResult result) onResult}) async {
    if (!_available) return;
    await _speech.listen(onResult: onResult, listenOptions: stt.SpeechListenOptions(partialResults: true));
  }

  Future<void> stop() => _speech.stop();
  Future<void> cancel() => _speech.cancel();
}
