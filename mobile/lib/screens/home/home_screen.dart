import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_provider.dart';
import '../../providers/orb_state_provider.dart';
import '../../widgets/orb/holographic_orb.dart';
import '../../widgets/chat/chat_list.dart';
import '../../widgets/chat/voice_input_button.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider);
    final error = ref.read(chatProvider.notifier).error;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white54),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ),
            const HolographicOrb(size: 160),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(error,
                    style: const TextStyle(color: Colors.redAccent)),
              ),
            Expanded(child: ChatList(messages: messages)),
            const Padding(
              padding: EdgeInsets.all(16),
              child: VoiceInputButton(),
            ),
          ],
        ),
      ),
    );
  }
}
