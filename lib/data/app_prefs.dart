import 'package:shared_preferences/shared_preferences.dart';

/// Remembers the farmer's language and district on the phone itself.
///
/// This is what makes the app stop asking. Once saved, the choice survives
/// closing the app, restarting the phone, even losing internet. It is only
/// erased if the app is uninstalled — exactly what Shruti asked for.
///
/// SharedPreferences is Android's small key-value store. It is the right tool
/// for a handful of settings like this. It is NOT the right tool for the
/// offline crop data later — that will need a proper database.
class AppPrefs {
  AppPrefs._();

  static const _keyLanguage = 'language_code';
  static const _keyDistrict = 'district_id';

  static Future<void> saveLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, code);
  }

  static Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage);
  }

  static Future<void> saveDistrict(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDistrict, id);
  }

  static Future<String?> getDistrict() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDistrict);
  }

  /// True only when BOTH have been chosen. The splash screen uses this to
  /// decide whether to show the setup screens or go straight to the dashboard.
  static Future<bool> isSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) != null &&
        prefs.getString(_keyDistrict) != null;
  }

  /// Wipes both choices. For now this is only used by a test button, so you
  /// can see the setup flow again without uninstalling the app. Later it
  /// becomes part of the Settings screen.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLanguage);
    await prefs.remove(_keyDistrict);
  }
}
