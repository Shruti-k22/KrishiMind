/// One language the app supports.
///
/// Keeping this as a small class (instead of loose strings scattered around)
/// means adding or removing a language later is a change in ONE list, not a
/// redesign. Shruti raised this point herself about the splash tagline — the
/// same thinking applies here.
class AppLanguage {
  final String code; // 'en', 'mr', 'hi' — the short standard code
  final String nativeName; // shown large: English / मराठी / हिंदी
  final String englishName; // shown small underneath
  final String continueLabel; // the button text, in this language

  const AppLanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.continueLabel,
  });
}

/// The three languages KrishiMind supports. Maharashtra only, so this is
/// deliberately short.
const List<AppLanguage> appLanguages = [
  AppLanguage(
    code: 'mr',
    nativeName: 'मराठी',
    englishName: 'Marathi',
    continueLabel: 'पुढे चला',
  ),
  AppLanguage(
    code: 'hi',
    nativeName: 'हिंदी',
    englishName: 'Hindi',
    continueLabel: 'आगे बढ़ें',
  ),
  AppLanguage(
    code: 'en',
    nativeName: 'English',
    englishName: 'English',
    continueLabel: 'Continue',
  ),
];

/// Which language is pre-selected when the screen opens.
///
/// Marathi, because the app is for Maharashtra and it is the state language.
/// This matters more than it looks: it means the Continue button always works,
/// even if the farmer doesn't understand that he is supposed to choose first.
/// A screen where nothing is selected and the button is greyed out is a dead
/// end for someone who can't read the instruction.
const int defaultLanguageIndex = 0;

/// Find a language by its saved code. Falls back to Marathi if the code is
/// missing or unrecognised.
AppLanguage findLanguageByCode(String? code) {
  for (final l in appLanguages) {
    if (l.code == code) return l;
  }
  return appLanguages[defaultLanguageIndex];
}
