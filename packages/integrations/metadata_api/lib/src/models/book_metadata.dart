import 'package:freezed_annotation/freezed_annotation.dart';

import 'metadata_base.dart';

part 'book_metadata.freezed.dart';
part 'book_metadata.g.dart';

@freezed
abstract class BookMetadata with _$BookMetadata implements MetadataBase {
  const factory BookMetadata({
    /// Google Books API ID
    required String id,

    /// Book title
    required String title,

    /// Subtitle (if available)
    String? subtitle,

    /// List of authors
    @Default([]) List<String> authors,

    /// Publisher name
    String? publisher,

    /// Published date (can be partial like "2023" or "2023-05")
    String? publishedDate,

    /// Description/summary
    String? description,

    /// ISBN-10 and ISBN-13
    @Default([]) List<String> isbn,

    /// Number of pages
    int? pageCount,

    /// Categories/genres
    @Default([]) List<String> categories,

    /// Average rating (0-5)
    double? averageRating,

    /// Number of ratings
    int? ratingsCount,

    /// Language code (e.g., "en", "ja")
    String? language,

    /// Preview link
    String? previewLink,

    /// Info link
    String? infoLink,

    /// Thumbnail URL
    String? thumbnailUrl,

    /// Small thumbnail URL
    String? smallThumbnailUrl,

    /// Additional metadata
    Map<String, dynamic>? additionalData,
  }) = _BookMetadata;

  const BookMetadata._();

  factory BookMetadata.fromJson(Map<String, dynamic> json) =>
      _$BookMetadataFromJson(json);

  /// Parse from Google Books API response
  factory BookMetadata.fromGoogleBooksJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;

    // Extract ISBNs
    final identifiers = volumeInfo['industryIdentifiers'] as List?;
    final isbnList =
        identifiers
            ?.map((e) => e['identifier'] as String?)
            .whereType<String>()
            .toList() ??
        [];

    return BookMetadata(
      id: json['id'] as String,
      title: volumeInfo['title'] as String? ?? 'Unknown',
      subtitle: volumeInfo['subtitle'] as String?,
      authors: (volumeInfo['authors'] as List?)?.cast<String>() ?? [],
      publisher: volumeInfo['publisher'] as String?,
      publishedDate: volumeInfo['publishedDate'] as String?,
      description: volumeInfo['description'] as String?,
      isbn: isbnList,
      pageCount: volumeInfo['pageCount'] as int?,
      categories: (volumeInfo['categories'] as List?)?.cast<String>() ?? [],
      averageRating: (volumeInfo['averageRating'] as num?)?.toDouble(),
      ratingsCount: volumeInfo['ratingsCount'] as int?,
      language: volumeInfo['language'] as String?,
      previewLink: volumeInfo['previewLink'] as String?,
      infoLink: volumeInfo['infoLink'] as String?,
      thumbnailUrl: imageLinks?['thumbnail'] as String?,
      smallThumbnailUrl: imageLinks?['smallThumbnail'] as String?,
      additionalData: json,
    );
  }

  @override
  DateTime? get releaseDate {
    if (publishedDate == null) return null;
    try {
      // Handle partial dates like "2023" or "2023-05"
      final parts = publishedDate!.split('-');
      final year = int.parse(parts[0]);
      final month = parts.length > 1 ? int.parse(parts[1]) : 1;
      final day = parts.length > 2 ? int.parse(parts[2]) : 1;
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  /// Get primary ISBN (prefer ISBN-13)
  String? get primaryIsbn {
    if (isbn.isEmpty) return null;

    // Try to find ISBN-13 first
    final isbn13 = isbn.firstWhere((i) => i.length == 13, orElse: () => '');

    if (isbn13.isNotEmpty) return isbn13;

    // Fall back to first ISBN
    return isbn.first;
  }

  /// Get formatted authors string
  String get authorsString {
    if (authors.isEmpty) return 'Unknown Author';
    if (authors.length == 1) return authors.first;
    if (authors.length == 2) return '${authors[0]} and ${authors[1]}';
    return '${authors[0]} and ${authors.length - 1} others';
  }
}
