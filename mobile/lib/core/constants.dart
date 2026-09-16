class VayuConstants {
  VayuConstants._();

  // ============================================================
  // APP
  // ============================================================

  static const String appName = 'Vayu AI';
  static const String appVersion = '0.0.1';

  static const String developerName =
      'Arni.Manikanta Teja Swaroop';

  // ============================================================
  // AI
  // ============================================================

  static const String defaultLanguage = 'en';

  static const String defaultModel =
      'gemini-2.5-flash';

  // API endpoints will be connected later.
  // Do NOT put Gemini/Grok API keys here.

  static const String chatEndpoint =
      '/api/chat';

  static const String translateEndpoint =
      '/api/translate';

  static const String conversationsEndpoint =
      '/api/conversations';

  static const String usageEndpoint =
      '/api/usage';

  // ============================================================
  // VAYU BEHAVIOUR
  // ============================================================

  static const String assistantName = 'Vayu';

  static const String developerTitle = 'Sir';

  static const String welcomeMessage =
      'Welcome home, Sir. Systems are online. '
      'What are we building tonight?';

  // ============================================================
  // LIMITS
  // ============================================================

  static const int maxMessageLength = 10000;

  static const int maxSavedTopics = 500;

  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String themeKey =
      'vayu_theme';

  static const String languageKey =
      'vayu_language';

  static const String developerModeKey =
      'vayu_developer_mode';

  static const String onboardingCompletedKey =
      'vayu_onboarding_completed';

  static const String savedTopicsKey =
      'vayu_saved_topics';

  static const String chatMemoryKey =
      'vayu_chat_memory';

  // ============================================================
  // FEATURES
  // ============================================================

  static const bool voiceEnabled = true;

  static const bool localMemoryEnabled = true;

  static const bool developerSettingsEnabled = true;

  static const bool apiKeyManagementEnabled = false;

  // This will become true only after secure
  // developer authentication + backend
  // API-key management are implemented.
}
