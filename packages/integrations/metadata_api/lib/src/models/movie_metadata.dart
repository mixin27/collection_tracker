import 'package:freezed_annotation/freezed_annotation.dart';

import 'metadata_base.dart';

part 'movie_metadata.freezed.dart';
part 'movie_metadata.g.dart';

@freezed
abstract class MovieMetadata with _$MovieMetadata implements MetadataBase {
  const factory MovieMetadata({
    /// TMDB API ID
    required String id,

    /// Movie title
    required String title,

    /// Original title (in original language)
    String? originalTitle,

    /// Tagline
    String? tagline,

    /// Overview/description
    String? description,

    /// Release date
    String? movieReleaseDate,

    /// Runtime in minutes
    int? runtime,

    /// Genres
    @Default([]) List<String> genres,

    /// Original language code
    String? originalLanguage,

    /// Production companies
    @Default([]) List<String> productionCompanies,

    /// Production countries
    @Default([]) List<String> productionCountries,

    /// Vote average (0-10)
    double? voteAverage,

    /// Vote count
    int? voteCount,

    /// Popularity score
    double? popularity,

    /// Poster path (relative)
    String? posterPath,

    /// Backdrop path (relative)
    String? backdropPath,

    /// Budget in USD
    int? budget,

    /// Revenue in USD
    int? revenue,

    /// Homepage URL
    String? homepage,

    /// IMDB ID
    String? imdbId,

    /// Additional metadata
    Map<String, dynamic>? additionalData,
  }) = _MovieMetadata;

  const MovieMetadata._();

  factory MovieMetadata.fromJson(Map<String, dynamic> json) =>
      _$MovieMetadataFromJson(json);

  /// Parse from TMDB API response
  factory MovieMetadata.fromTMDBJson(Map<String, dynamic> json) {
    return MovieMetadata(
      id: json['id'].toString(),
      title: json['title'] as String? ?? 'Unknown',
      originalTitle: json['original_title'] as String?,
      tagline: json['tagline'] as String?,
      description: json['overview'] as String?,
      movieReleaseDate: json['release_date'] as String?,
      runtime: json['runtime'] as int?,
      genres: _extractGenres(json['genres']),
      originalLanguage: json['original_language'] as String?,
      productionCompanies: _extractCompanies(json['production_companies']),
      productionCountries: _extractCountries(json['production_countries']),
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'] as int?,
      popularity: (json['popularity'] as num?)?.toDouble(),
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      budget: json['budget'] as int?,
      revenue: json['revenue'] as int?,
      homepage: json['homepage'] as String?,
      imdbId: json['imdb_id'] as String?,
      additionalData: json,
    );
  }

  static const _tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';

  @override
  String? get thumbnailUrl {
    if (posterPath == null) return null;
    return '$_tmdbImageBaseUrl/w342$posterPath';
  }

  /// Get full-size poster URL
  String? get posterUrl {
    if (posterPath == null) return null;
    return '$_tmdbImageBaseUrl/w500$posterPath';
  }

  /// Get backdrop URL
  String? get backdropUrl {
    if (backdropPath == null) return null;
    return '$_tmdbImageBaseUrl/w1280$backdropPath';
  }

  @override
  DateTime? get releaseDate {
    if (movieReleaseDate == null) return null;
    try {
      return DateTime.parse(movieReleaseDate!);
    } catch (e) {
      return null;
    }
  }

  /// Get runtime as formatted string (e.g., "2h 15m")
  String? get runtimeFormatted {
    if (runtime == null) return null;
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  // Helper methods for parsing TMDB response
  static List<String> _extractGenres(dynamic genres) {
    if (genres == null) return [];
    if (genres is! List) return [];
    return genres.map((e) => e['name'] as String?).whereType<String>().toList();
  }

  static List<String> _extractCompanies(dynamic companies) {
    if (companies == null) return [];
    if (companies is! List) return [];
    return companies
        .map((e) => e['name'] as String?)
        .whereType<String>()
        .toList();
  }

  static List<String> _extractCountries(dynamic countries) {
    if (countries == null) return [];
    if (countries is! List) return [];
    return countries
        .map((e) => e['name'] as String?)
        .whereType<String>()
        .toList();
  }
}
