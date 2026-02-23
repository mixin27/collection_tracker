enum AnalyticsConsentStatus { unknown, granted, denied }

extension AnalyticsConsentStatusX on AnalyticsConsentStatus {
  String get code => switch (this) {
    AnalyticsConsentStatus.unknown => 'unknown',
    AnalyticsConsentStatus.granted => 'granted',
    AnalyticsConsentStatus.denied => 'denied',
  };

  static AnalyticsConsentStatus fromCode(String? code) {
    return switch (code) {
      'granted' => AnalyticsConsentStatus.granted,
      'denied' => AnalyticsConsentStatus.denied,
      _ => AnalyticsConsentStatus.unknown,
    };
  }
}

class AnalyticsPreferences {
  const AnalyticsPreferences({
    required this.enabled,
    required this.consentStatus,
  });

  static const enabledPrefKey = 'analytics_enabled';
  static const consentStatusPrefKey = 'analytics_consent_status';

  final bool enabled;
  final AnalyticsConsentStatus consentStatus;

  bool get needsConsent =>
      enabled && consentStatus == AnalyticsConsentStatus.unknown;
  bool get canTrack =>
      enabled && consentStatus == AnalyticsConsentStatus.granted;

  AnalyticsPreferences copyWith({
    bool? enabled,
    AnalyticsConsentStatus? consentStatus,
  }) {
    return AnalyticsPreferences(
      enabled: enabled ?? this.enabled,
      consentStatus: consentStatus ?? this.consentStatus,
    );
  }
}
