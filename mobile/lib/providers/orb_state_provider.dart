import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Drives both the shader's energy uniform and any voice service hooks.
enum OrbState { idle, listening, thinking, speaking }

class OrbStateNotifier extends StateNotifier<OrbState> {
  OrbStateNotifier() : super(OrbState.idle);

  void setListening() => state = OrbState.listening;
  void setThinking() => state = OrbState.thinking;
  void setSpeaking() => state = OrbState.speaking;
  void setIdle() => state = OrbState.idle;
}

final orbStateProvider =
    StateNotifierProvider<OrbStateNotifier, OrbState>((ref) {
  return OrbStateNotifier();
});

/// Maps state to a 0-1 energy value consumed by the GLSL shader.
double energyForState(OrbState s) {
  switch (s) {
    case OrbState.idle:
      return 0.15;
    case OrbState.listening:
      return 0.6;
    case OrbState.thinking:
      return 0.85;
    case OrbState.speaking:
      return 1.0;
  }
}
