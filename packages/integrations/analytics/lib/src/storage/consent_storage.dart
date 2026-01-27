import 'package:shared_preferences/shared_preferences.dart';

/// Storage for user consent preferences
class ConsentStorage {
  static const _consentKey = 'analytics_consent';

  /// Check if user has granted consent
  Future<bool> hasConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  /// Set user consent
  Future<void> setConsent(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, granted);
  }

  /// Clear consent (for testing)
  Future<void> clearConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_consentKey);
  }
}
