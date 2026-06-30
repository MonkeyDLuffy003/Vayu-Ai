import 'package:flutter/material.dart';
import '../../widgets/common/language_selector.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E14),
        title: const Text('Language'),
      ),
      body: const LanguageSelector(),
    );
  }
}
