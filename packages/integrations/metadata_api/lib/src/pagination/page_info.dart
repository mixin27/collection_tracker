import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_info.freezed.dart';
part 'page_info.g.dart';

/// Information about the current page in a paginated result
@freezed
abstract class PageInfo with _$PageInfo {
  const factory PageInfo({
    /// Current page number (1-based)
    required int currentPage,

    /// Number of items per page
    required int pageSize,

    /// Total number of items across all pages
    /// -1 if unknown (e.g., cursor-based pagination)
    required int totalItems,

    /// Total number of pages
    /// -1 if unknown (e.g., cursor-based pagination)
    required int totalPages,

    /// Whether there is a next page
    required bool hasNextPage,

    /// Whether there is a previous page
    required bool hasPreviousPage,

    /// Cursor for next page (for cursor-based pagination)
    String? nextCursor,

    /// Cursor for previous page (for cursor-based pagination)
    String? previousCursor,
  }) = _PageInfo;

  factory PageInfo.fromJson(Map<String, dynamic> json) =>
      _$PageInfoFromJson(json);
}

/// Helper extensions for PageInfo
extension PageInfoX on PageInfo {
  /// Check if this is the first page
  bool get isFirstPage => currentPage == 1;

  /// Check if this is the last page
  bool get isLastPage => !hasNextPage;

  /// Get the start index of items in the current page (0-based)
  int get startIndex => (currentPage - 1) * pageSize;

  /// Get the end index of items in the current page (0-based, exclusive)
  int get endIndex => startIndex + pageSize;

  /// Create a copy with updated page number
  PageInfo nextPage() {
    if (!hasNextPage) return this;

    return copyWith(
      currentPage: currentPage + 1,
      hasPreviousPage: true,
      hasNextPage: currentPage + 1 < totalPages,
    );
  }

  /// Create a copy for previous page
  PageInfo previousPage() {
    if (!hasPreviousPage) return this;

    return copyWith(
      currentPage: currentPage - 1,
      hasPreviousPage: currentPage - 1 > 1,
      hasNextPage: true,
    );
  }
}
