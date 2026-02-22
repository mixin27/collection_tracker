class FirebaseRuntimeConfig {
  const FirebaseRuntimeConfig({
    required this.analyticsCollectionEnabled,
    required this.crashlyticsCollectionEnabled,
    required this.performanceCollectionEnabled,
    required this.syncFeatureEnabled,
  });

  static const defaults = FirebaseRuntimeConfig(
    analyticsCollectionEnabled: true,
    crashlyticsCollectionEnabled: true,
    performanceCollectionEnabled: true,
    syncFeatureEnabled: false,
  );

  final bool analyticsCollectionEnabled;
  final bool crashlyticsCollectionEnabled;
  final bool performanceCollectionEnabled;
  final bool syncFeatureEnabled;
}
