class VayuLanguage {
  final String code;
  final String name;
  final String speechLocale;
  final String ttsLocale;

  const VayuLanguage({
    required this.code,
    required this.name,
    required this.speechLocale,
    required this.ttsLocale,
  });
}

class LanguageService {
  LanguageService._();

  static const List<VayuLanguage> supportedLanguages = [
    // Indian languages
    VayuLanguage(
      code: 'en',
      name: 'English',
      speechLocale: 'en_US',
      ttsLocale: 'en-US',
    ),
    VayuLanguage(
      code: 'te',
      name: 'Telugu',
      speechLocale: 'te_IN',
      ttsLocale: 'te-IN',
    ),
    VayuLanguage(
      code: 'hi',
      name: 'Hindi',
      speechLocale: 'hi_IN',
      ttsLocale: 'hi-IN',
    ),
    VayuLanguage(
      code: 'ta',
      name: 'Tamil',
      speechLocale: 'ta_IN',
      ttsLocale: 'ta-IN',
    ),
    VayuLanguage(
      code: 'kn',
      name: 'Kannada',
      speechLocale: 'kn_IN',
      ttsLocale: 'kn-IN',
    ),
    VayuLanguage(
      code: 'ml',
      name: 'Malayalam',
      speechLocale: 'ml_IN',
      ttsLocale: 'ml-IN',
    ),
    VayuLanguage(
      code: 'bn',
      name: 'Bengali',
      speechLocale: 'bn_IN',
      ttsLocale: 'bn-IN',
    ),
    VayuLanguage(
      code: 'mr',
      name: 'Marathi',
      speechLocale: 'mr_IN',
      ttsLocale: 'mr-IN',
    ),
    VayuLanguage(
      code: 'gu',
      name: 'Gujarati',
      speechLocale: 'gu_IN',
      ttsLocale: 'gu-IN',
    ),
    VayuLanguage(
      code: 'pa',
      name: 'Punjabi',
      speechLocale: 'pa_IN',
      ttsLocale: 'pa-IN',
    ),
    VayuLanguage(
      code: 'ur',
      name: 'Urdu',
      speechLocale: 'ur_IN',
      ttsLocale: 'ur-IN',
    ),

    // Southeast Asian languages
    VayuLanguage(
      code: 'id',
      name: 'Indonesian',
      speechLocale: 'id_ID',
      ttsLocale: 'id-ID',
    ),
    VayuLanguage(
      code: 'fil',
      name: 'Filipino',
      speechLocale: 'fil_PH',
      ttsLocale: 'fil-PH',
    ),
    VayuLanguage(
      code: 'th',
      name: 'Thai',
      speechLocale: 'th_TH',
      ttsLocale: 'th-TH',
    ),
    VayuLanguage(
      code: 'vi',
      name: 'Vietnamese',
      speechLocale: 'vi_VN',
      ttsLocale: 'vi-VN',
    ),

    // East Asian languages
    VayuLanguage(
      code: 'ja',
      name: 'Japanese',
      speechLocale: 'ja_JP',
      ttsLocale: 'ja-JP',
    ),
    VayuLanguage(
      code: 'ko',
      name: 'Korean',
      speechLocale: 'ko_KR',
      ttsLocale: 'ko-KR',
    ),

    // European languages
    VayuLanguage(
      code: 'ru',
      name: 'Russian',
      speechLocale: 'ru_RU',
      ttsLocale: 'ru-RU',
    ),
    VayuLanguage(
      code: 'fr',
      name: 'French',
      speechLocale: 'fr_FR',
      ttsLocale: 'fr-FR',
    ),
  ];

  static VayuLanguage getByCode(String code) {
    return supportedLanguages.firstWhere(
      (language) => language.code == code,
      orElse: () => supportedLanguages.first,
    );
  }

  static VayuLanguage get defaultLanguage {
    return supportedLanguages.first;
  }

  static bool isSupported(String code) {
    return supportedLanguages.any(
      (language) => language.code == code,
    );
  }

  static String getSpeechLocale(String code) {
    return getByCode(code).speechLocale;
  }

  static String getTtsLocale(String code) {
    return getByCode(code).ttsLocale;
  }

  static String getDisplayName(String code) {
    return getByCode(code).name;
  }
}
