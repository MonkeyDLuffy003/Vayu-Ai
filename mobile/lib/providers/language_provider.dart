import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'preferred_language';

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('en') {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_prefsKey) ?? 'en';
  }

  Future<void> setLanguage(String code) async {
    state = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
  }
}

final languageProvider =
    StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});
