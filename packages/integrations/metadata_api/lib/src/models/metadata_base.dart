/// Base interface for all metadata types
abstract class MetadataBase {
  /// Unique identifier from the API
  String get id;

  /// Title of the item
  String get title;

  /// Description or summary
  String? get description;

  /// Thumbnail image URL
  String? get thumbnailUrl;

  /// Release/publish date
  DateTime? get releaseDate;

  /// Convert to JSON
  Map<String, dynamic> toJson();
}
