import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/languages.dart';
import '../../providers/language_provider.dart';
import '../../providers/chat_provider.dart';
import 'language_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _launchingCheckout = false;

  Future<void> _upgradeToPro() async {
    setState(() => _launchingCheckout = true);
    try {
      final api = ref.read(apiServiceProvider);
      final url = await api.createProCheckoutSession();
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start checkout. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _launchingCheckout = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = languageForCode(ref.watch(languageProvider));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E14),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Language', style: TextStyle(color: Colors.white)),
            subtitle: Text(currentLanguage.nativeName,
                style: const TextStyle(color: Colors.white54)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LanguageScreen()),
            ),
          ),
          const Divider(color: Color(0xFF1E2430)),
          ListTile(
            title: const Text('Upgrade to Pro',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text('More messages per day, priority response time',
                style: TextStyle(color: Colors.white54)),
            trailing: _launchingCheckout
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: _launchingCheckout ? null : _upgradeToPro,
          ),
        ],
      ),
    );
  }
}
