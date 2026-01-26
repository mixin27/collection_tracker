import 'package:domain/domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:metadata_api/metadata_api.dart';

class MetadataMatchResult {
  final MetadataBase? metadata;
  final double confidence;
  final String source;

  MetadataMatchResult({
    this.metadata,
    required this.confidence,
    required this.source,
  });
}

class SmartMetadataMatcher {
  final UnifiedMetadataService _service;

  SmartMetadataMatcher(this._service);

  /// Try to find metadata across multiple sources and return best match
  Future<Either<AppException, MetadataMatchResult>> findBestMatch({
    required String barcode,
    required CollectionType primaryType,
    List<CollectionType>? fallbackTypes,
  }) async {
    // Try primary type first
    final primaryResult = await _service.fetchByBarcode(
      barcode: barcode,
      collectionType: primaryType,
    );

    final primaryMatch = primaryResult.fold(
      (exception) => null,
      (metadata) => metadata != null
          ? MetadataMatchResult(
              metadata: metadata,
              confidence: 1.0,
              source: primaryType.name,
            )
          : null,
    );

    if (primaryMatch != null) {
      return Right(primaryMatch);
    }

    // Try fallback types if provided
    if (fallbackTypes != null) {
      for (final fallbackType in fallbackTypes) {
        final fallbackResult = await _service.fetchByBarcode(
          barcode: barcode,
          collectionType: fallbackType,
        );

        final fallbackMatch = fallbackResult.fold(
          (exception) => null,
          (metadata) => metadata != null
              ? MetadataMatchResult(
                  metadata: metadata,
                  confidence: 0.7,
                  source: fallbackType.name,
                )
              : null,
        );

        if (fallbackMatch != null) {
          return Right(fallbackMatch);
        }
      }
    }

    // No match found
    return Right(
      MetadataMatchResult(metadata: null, confidence: 0.0, source: 'none'),
    );
  }
}
