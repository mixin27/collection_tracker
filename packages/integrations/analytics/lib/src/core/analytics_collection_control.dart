/// Optional capability for providers that can toggle SDK-side collection.
abstract interface class AnalyticsCollectionControl {
  Future<void> setCollectionEnabled(bool enabled);
}
