class LanguageOption {
  const LanguageOption(this.code, this.englishName, this.nativeName);
  final String code;
  final String englishName;
  final String nativeName;
}

/// 18 languages — English plus 17 Indian languages, matching Vayu AI's
/// target audience. `code` is what the backend sends to Grok as the
/// translation target and what gets persisted as the user's preference.
const List<LanguageOption> kSupportedLanguages = [
  LanguageOption('en', 'English', 'English'),
  LanguageOption('hi', 'Hindi', 'हिन्दी'),
  LanguageOption('te', 'Telugu', 'తెలుగు'),
  LanguageOption('ta', 'Tamil', 'தமிழ்'),
  LanguageOption('kn', 'Kannada', 'ಕನ್ನಡ'),
  LanguageOption('ml', 'Malayalam', 'മലയാളം'),
  LanguageOption('mr', 'Marathi', 'मराठी'),
  LanguageOption('gu', 'Gujarati', 'ગુજરાતી'),
  LanguageOption('bn', 'Bengali', 'বাংলা'),
  LanguageOption('pa', 'Punjabi', 'ਪੰਜਾਬੀ'),
  LanguageOption('or', 'Odia', 'ଓଡ଼ିଆ'),
  LanguageOption('as', 'Assamese', 'অসমীয়া'),
  LanguageOption('ur', 'Urdu', 'اردو'),
  LanguageOption('sa', 'Sanskrit', 'संस्कृतम्'),
  LanguageOption('kok', 'Konkani', 'कोंकणी'),
  LanguageOption('mai', 'Maithili', 'मैथिली'),
  LanguageOption('ne', 'Nepali', 'नेपाली'),
  LanguageOption('sd', 'Sindhi', 'سنڌي'),
];

LanguageOption languageForCode(String code) => kSupportedLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => kSupportedLanguages.first,
    );
