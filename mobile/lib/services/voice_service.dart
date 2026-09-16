import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _speechInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;

  /// Initialize speech recognition and text-to-speech.
  Future<bool> initialize({
    void Function(String status)? onStatus,
    void Function(dynamic error)? onError,
  }) async {
    try {
      _speechInitialized = await _speech.initialize(
        onStatus: onStatus,
        onError: onError,
      );

      await _tts.awaitSpeakCompletion(true);

      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      return _speechInitialized;
    } catch (_) {
      _speechInitialized = false;
      return false;
    }
  }

  /// Start microphone listening.
  Future<bool> startListening({
    required void Function(String text, bool isFinal) onResult,
    String localeId = 'en_US',
  }) async {
    if (!_speechInitialized) {
      final initialized = await initialize();

      if (!initialized) {
        return false;
      }
    }

    try {
      if (_speech.isListening) {
        await _speech.stop();
      }

      _isListening = true;

      await _speech.listen(
        localeId: localeId,
        onResult: (result) {
          onResult(
            result.recognizedWords,
            result.finalResult,
          );

          if (result.finalResult) {
            _isListening = false;
          }
        },
      );

      return true;
    } catch (_) {
      _isListening = false;
      return false;
    }
  }

  /// Stop microphone listening.
  Future<void> stopListening() async {
    try {
      await _speech.stop();
    } finally {
      _isListening = false;
    }
  }

  /// Cancel microphone listening.
  Future<void> cancelListening() async {
    try {
      await _speech.cancel();
    } finally {
      _isListening = false;
    }
  }

  /// Speak Vayu's response.
  Future<bool> speak(
    String text, {
    String language = 'en-US',
  }) async {
    if (text.trim().isEmpty) {
      return false;
    }

    try {
      await stopSpeaking();

      await _tts.setLanguage(language);
      _isSpeaking = true;

      final result = await _tts.speak(text);

      _isSpeaking = false;

      return result == 1 || result == true;
    } catch (_) {
      _isSpeaking = false;
      return false;
    }
  }

  /// Stop Vayu's voice output.
  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } finally {
      _isSpeaking = false;
    }
  }

  /// Change Vayu's speaking speed.
  Future<void> setSpeechRate(double rate) async {
    final safeRate = rate.clamp(0.2, 0.8);
    await _tts.setSpeechRate(safeRate);
  }

  /// Change Vayu's voice pitch.
  Future<void> setPitch(double pitch) async {
    final safePitch = pitch.clamp(0.5, 2.0);
    await _tts.setPitch(safePitch);
  }

  /// Change Vayu's volume.
  Future<void> setVolume(double volume) async {
    final safeVolume = volume.clamp(0.0, 1.0);
    await _tts.setVolume(safeVolume);
  }

  /// Check whether speech recognition is currently available.
  Future<bool> isSpeechAvailable() async {
    if (!_speechInitialized) {
      return await initialize();
    }

    return true;
  }

  /// Release resources.
  Future<void> dispose() async {
    await cancelListening();
    await stopSpeaking();
  }
}
