import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/languages.dart';
import '../../providers/language_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(languageProvider);

    return ListView.separated(
      itemCount: kSupportedLanguages.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFF1E2430)),
      itemBuilder: (context, index) {
        final lang = kSupportedLanguages[index];
        final isSelected = lang.code == selected;
        return ListTile(
          title: Text(lang.nativeName,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          subtitle: Text(lang.englishName,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Color(0xFF2B6CB0))
              : null,
          onTap: () => ref.read(languageProvider.notifier).setLanguage(lang.code),
        );
      },
    );
  }
}
