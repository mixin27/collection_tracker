class FirebaseRuntimeConfig {
  const FirebaseRuntimeConfig({
    required this.analyticsCollectionEnabled,
    required this.crashlyticsCollectionEnabled,
    required this.performanceCollectionEnabled,
  });

  static const defaults = FirebaseRuntimeConfig(
    analyticsCollectionEnabled: true,
    crashlyticsCollectionEnabled: true,
    performanceCollectionEnabled: true,
  );

  final bool analyticsCollectionEnabled;
  final bool crashlyticsCollectionEnabled;
  final bool performanceCollectionEnabled;
}
