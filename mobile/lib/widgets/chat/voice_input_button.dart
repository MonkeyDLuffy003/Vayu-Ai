import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../providers/chat_provider.dart';
import '../../providers/orb_state_provider.dart';

class VoiceInputButton extends ConsumerStatefulWidget {
  const VoiceInputButton({super.key});

  @override
  ConsumerState<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends ConsumerState<VoiceInputButton> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _listening = false;

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      ref.read(orbStateProvider.notifier).setIdle();
      return;
    }

    final available = await _speech.initialize(
      onError: (e) => debugPrint('speech_error: $e'),
    );
    if (!available) return;

    setState(() => _listening = true);
    ref.read(orbStateProvider.notifier).setListening();

    _speech.listen(
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          ref.read(chatProvider.notifier).sendMessage(result.recognizedWords);
          setState(() => _listening = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleListening,
      child: CircleAvatar(
        radius: 32,
        backgroundColor: _listening ? Colors.redAccent : const Color(0xFF2B6CB0),
        child: Icon(_listening ? Icons.mic : Icons.mic_none,
            color: Colors.white, size: 28),
      ),
    );
  }
}
