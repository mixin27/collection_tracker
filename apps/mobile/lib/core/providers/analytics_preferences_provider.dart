import 'package:app_analytics/app_analytics.dart';
import 'package:collection_tracker/core/analytics/analytics_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:storage/storage.dart';

part 'analytics_preferences_provider.g.dart';

@riverpod
class AnalyticsPreferencesNotifier extends _$AnalyticsPreferencesNotifier {
  late final PrefsStorageService _prefs;

  @override
  AnalyticsPreferences build() {
    _prefs = PrefsStorageService.instance;
    final enabled =
        _prefs.readSync<bool>(AnalyticsPreferences.enabledPrefKey) ?? true;
    final consentCode = _prefs.readSync<String>(
      AnalyticsPreferences.consentStatusPrefKey,
    );
    final consentStatus = AnalyticsConsentStatusX.fromCode(consentCode);

    return AnalyticsPreferences(enabled: enabled, consentStatus: consentStatus);
  }

  Future<void> setEnabled(bool enabled) async {
    await _prefs.save<bool>(AnalyticsPreferences.enabledPrefKey, enabled);
    state = state.copyWith(enabled: enabled);
    await _applyToAnalyticsService();
  }

  Future<void> grantConsent() =>
      setConsentStatus(AnalyticsConsentStatus.granted);

  Future<void> denyConsent() => setConsentStatus(AnalyticsConsentStatus.denied);

  Future<void> resetConsent() =>
      setConsentStatus(AnalyticsConsentStatus.unknown);

  Future<void> setConsentStatus(AnalyticsConsentStatus status) async {
    await _prefs.save<String>(
      AnalyticsPreferences.consentStatusPrefKey,
      status.code,
    );
    state = state.copyWith(consentStatus: status);
    await _applyToAnalyticsService();
  }

  Future<void> _applyToAnalyticsService() async {
    final analytics = AnalyticsService.instance;
    if (!analytics.isInitialized) return;

    await analytics.setTrackingEnabled(state.enabled);
    await analytics.setConsentGranted(
      state.consentStatus == AnalyticsConsentStatus.granted,
    );
  }
}
