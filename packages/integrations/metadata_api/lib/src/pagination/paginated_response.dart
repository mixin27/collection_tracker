import 'package:freezed_annotation/freezed_annotation.dart';

import 'page_info.dart';

part 'paginated_response.freezed.dart';

/// Generic paginated response wrapper
@Freezed(genericArgumentFactories: true)
abstract class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const factory PaginatedResponse({
    /// List of items in the current page
    required List<T> items,

    /// Pagination information
    required PageInfo pageInfo,

    /// Optional metadata about the response
    Map<String, dynamic>? metadata,
  }) = _PaginatedResponse<T>;

  const PaginatedResponse._();

  /// Check if there are any items
  bool get isEmpty => items.isEmpty;

  /// Check if there are items
  bool get isNotEmpty => items.isNotEmpty;

  /// Get the number of items in current page
  int get length => items.length;

  /// Map items to a different type
  PaginatedResponse<R> map<R>(R Function(T) mapper) {
    return PaginatedResponse(
      items: items.map(mapper).toList(),
      pageInfo: pageInfo,
      metadata: metadata,
    );
  }
}
