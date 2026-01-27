import 'package:app_analytics/app_analytics.dart';

/// Collection events
class CollectionEvents {
  /// Collection created
  static AnalyticsEvent collectionCreated({
    required String collectionType,
    String? collectionName,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'collection_created',
      category: 'collection',
      properties: {
        'collection_type': collectionType,
        if (collectionName != null) 'collection_name': collectionName,
        ...?properties,
      },
    );
  }

  /// Item added to collection
  static AnalyticsEvent itemAdded({
    required String collectionType,
    required String source, // 'barcode', 'manual', 'search'
    bool? metadataFound,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'item_added',
      category: 'collection',
      properties: {
        'collection_type': collectionType,
        'source': source,
        if (metadataFound != null) 'metadata_found': metadataFound,
        ...?properties,
      },
    );
  }

  /// Barcode scanned
  static AnalyticsEvent barcodeScanned({
    required String collectionType,
    bool? successful,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent.custom(
      name: 'barcode_scanned',
      category: 'collection',
      properties: {
        'collection_type': collectionType,
        if (successful != null) 'successful': successful,
        ...?properties,
      },
    );
  }
}
