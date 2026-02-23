class FirebaseRuntimeConfig {
  const FirebaseRuntimeConfig({
    required this.analyticsCollectionEnabled,
    required this.crashlyticsCollectionEnabled,
    required this.performanceCollectionEnabled,
    required this.appCheckEnabled,
    required this.fcmEnabled,
    required this.metadataFeatureEnabled,
    required this.backendIntegrationEnabled,
    required this.authFeatureEnabled,
    required this.syncFeatureEnabled,
  });

  static const defaults = FirebaseRuntimeConfig(
    analyticsCollectionEnabled: true,
    crashlyticsCollectionEnabled: true,
    performanceCollectionEnabled: true,
    appCheckEnabled: false,
    fcmEnabled: false,
    metadataFeatureEnabled: true,
    backendIntegrationEnabled: false,
    authFeatureEnabled: true,
    syncFeatureEnabled: false,
  );

  final bool analyticsCollectionEnabled;
  final bool crashlyticsCollectionEnabled;
  final bool performanceCollectionEnabled;
  final bool appCheckEnabled;
  final bool fcmEnabled;
  final bool metadataFeatureEnabled;
  final bool backendIntegrationEnabled;
  final bool authFeatureEnabled;
  final bool syncFeatureEnabled;
}
