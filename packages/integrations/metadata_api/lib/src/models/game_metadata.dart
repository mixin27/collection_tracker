import 'package:freezed_annotation/freezed_annotation.dart';

import 'metadata_base.dart';

part 'game_metadata.freezed.dart';
part 'game_metadata.g.dart';

@freezed
abstract class GameMetadata with _$GameMetadata implements MetadataBase {
  const factory GameMetadata({
    /// IGDB API ID
    required String id,

    /// Game title
    required String title,

    /// Alternative names
    @Default([]) List<String> alternativeNames,

    /// Description/summary
    String? description,

    /// Storyline (longer description)
    String? storyline,

    /// Release date (Unix timestamp)
    int? releaseDateTimestamp,

    /// Genres
    @Default([]) List<String> genres,

    /// Platforms (PS5, Xbox, PC, etc.)
    @Default([]) List<String> platforms,

    /// Game modes (Single player, Multiplayer, etc.)
    @Default([]) List<String> gameModes,

    /// Developers
    @Default([]) List<String> developers,

    /// Publishers
    @Default([]) List<String> publishers,

    /// Rating (0-100)
    double? rating,

    /// Number of ratings
    int? ratingCount,

    /// Cover image URL
    String? coverUrl,

    /// Screenshot URLs
    @Default([]) List<String> screenshots,

    /// Official website
    String? website,

    /// Additional metadata
    Map<String, dynamic>? additionalData,
  }) = _GameMetadata;

  const GameMetadata._();

  factory GameMetadata.fromJson(Map<String, dynamic> json) =>
      _$GameMetadataFromJson(json);

  /// Parse from IGDB API response
  factory GameMetadata.fromIGDBJson(Map<String, dynamic> json) {
    return GameMetadata(
      id: json['id'].toString(),
      title: json['name'] as String? ?? 'Unknown',
      alternativeNames: _extractNames(json['alternative_names']),
      description: json['summary'] as String?,
      storyline: json['storyline'] as String?,
      releaseDateTimestamp: _extractFirstReleaseDate(json['release_dates']),
      genres: _extractNames(json['genres']),
      platforms: _extractNames(json['platforms']),
      gameModes: _extractNames(json['game_modes']),
      developers: _extractCompanyNames(json['involved_companies'], 'developer'),
      publishers: _extractCompanyNames(json['involved_companies'], 'publisher'),
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: json['rating_count'] as int?,
      coverUrl: _extractImageUrl(json['cover']),
      screenshots: _extractScreenshots(json['screenshots']),
      website: json['url'] as String?,
      additionalData: json,
    );
  }

  @override
  String? get thumbnailUrl => coverUrl;

  @override
  DateTime? get releaseDate {
    if (releaseDateTimestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(releaseDateTimestamp! * 1000);
  }

  /// Get formatted platforms string
  String get platformsString {
    if (platforms.isEmpty) return 'Unknown Platform';
    if (platforms.length <= 3) return platforms.join(', ');
    return '${platforms.take(3).join(', ')} and ${platforms.length - 3} more';
  }

  // Helper methods for parsing IGDB response
  static List<String> _extractNames(dynamic field) {
    if (field == null) return [];
    if (field is! List) return [];
    return field.map((e) => e['name'] as String?).whereType<String>().toList();
  }

  static int? _extractFirstReleaseDate(dynamic releaseDates) {
    if (releaseDates == null) return null;
    if (releaseDates is! List || releaseDates.isEmpty) return null;
    return releaseDates.first['date'] as int?;
  }

  static List<String> _extractCompanyNames(dynamic companies, String role) {
    if (companies == null) return [];
    if (companies is! List) return [];

    return companies
        .where((c) => c[role] == true)
        .map((c) => c['company']?['name'] as String?)
        .whereType<String>()
        .toList();
  }

  static String? _extractImageUrl(dynamic cover) {
    if (cover == null) return null;
    if (cover is! Map) return null;

    final imageId = cover['image_id'] as String?;
    if (imageId == null) return null;

    return 'https://images.igdb.com/igdb/image/upload/t_cover_big/$imageId.jpg';
  }

  static List<String> _extractScreenshots(dynamic screenshots) {
    if (screenshots == null) return [];
    if (screenshots is! List) return [];

    return screenshots
        .map((s) {
          final imageId = s['image_id'] as String?;
          if (imageId == null) return null;
          return 'https://images.igdb.com/igdb/image/upload/t_screenshot_med/$imageId.jpg';
        })
        .whereType<String>()
        .toList();
  }
}
