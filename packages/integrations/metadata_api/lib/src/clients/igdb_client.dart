// ignore_for_file: unused_field

import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:fpdart/fpdart.dart';

import '../models/game_metadata.dart';
import '../pagination/page_info.dart';
import '../pagination/paginated_response.dart';

/// Client for IGDB (Internet Game Database) API
/// API Documentation: https://api-docs.igdb.com/
///
/// Note: IGDB uses Twitch OAuth for authentication
class IGDBClient {
  IGDBClient({required String clientId, required String accessToken, Dio? dio})
    : _clientId = clientId,
      _accessToken = accessToken,
      _dio = dio ?? _createDefaultDio(clientId, accessToken);

  static const _baseUrl = 'https://api.igdb.com/v4';

  final Dio _dio;
  final String _clientId;
  final String _accessToken;

  static Dio _createDefaultDio(String clientId, String accessToken) {
    return Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Client-ID': clientId,
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Search games by query with pagination
  ///
  /// Example:
  /// ```dart
  /// final result = await client.searchGames(
  ///   query: 'zelda',
  ///   page: 1,
  ///   pageSize: 10,
  /// );
  /// ```
  Future<Either<AppException, PaginatedResponse<GameMetadata>>> searchGames({
    required String query,
    int page = 1,
    int pageSize = 10,
    String? platforms,
    int? yearFrom,
    int? yearTo,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return Left(
          AppException.validation(message: 'Search query cannot be empty'),
        );
      }

      final offset = (page - 1) * pageSize;

      // Build IGDB query (Apicalypse format)
      final igdbQuery = _buildSearchQuery(
        query: query,
        offset: offset,
        limit: pageSize,
        platforms: platforms,
        yearFrom: yearFrom,
        yearTo: yearTo,
      );

      final response = await _dio.post('/games', data: igdbQuery);

      final items = (response.data as List)
          .map(
            (json) => GameMetadata.fromIGDBJson(json as Map<String, dynamic>),
          )
          .toList();

      // IGDB doesn't return total count in search, so we estimate
      final hasMore = items.length == pageSize;

      final pageInfo = PageInfo(
        currentPage: page,
        pageSize: pageSize,
        totalItems: -1, // Unknown for IGDB
        totalPages: -1, // Unknown for IGDB
        hasNextPage: hasMore,
        hasPreviousPage: page > 1,
      );

      return Right(PaginatedResponse(items: items, pageInfo: pageInfo));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e, stackTrace) {
      return Left(
        AppException.unknown(
          message: 'Failed to search games: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get game by ID
  Future<Either<AppException, GameMetadata>> getGameById(String gameId) async {
    try {
      if (gameId.trim().isEmpty) {
        return Left(
          AppException.validation(message: 'Game ID cannot be empty'),
        );
      }

      final igdbQuery =
          '''
        fields
          name,
          alternative_names.name,
          summary,
          storyline,
          release_dates.date,
          genres.name,
          platforms.name,
          game_modes.name,
          involved_companies.company.name,
          involved_companies.developer,
          involved_companies.publisher,
          rating,
          rating_count,
          cover.image_id,
          screenshots.image_id,
          url;
        where id = $gameId;
      ''';

      final response = await _dio.post('/games', data: igdbQuery);

      final items = response.data as List;

      if (items.isEmpty) {
        return Left(
          AppException.notFound(
            message: 'Game not found',
            resourceType: 'Game',
            resourceId: gameId,
          ),
        );
      }

      final metadata = GameMetadata.fromIGDBJson(
        items.first as Map<String, dynamic>,
      );

      return Right(metadata);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e, stackTrace) {
      return Left(
        AppException.unknown(
          message: 'Failed to fetch game: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Search games by barcode (UPC)
  /// Note: IGDB doesn't directly support UPC search, so this searches by name
  Future<Either<AppException, List<GameMetadata>>> searchByBarcode(
    String barcode,
  ) async {
    // IGDB doesn't have direct barcode support
    // This is a placeholder that returns empty results
    // In practice, you'd need a barcode-to-game mapping service
    return const Right([]);
  }

  /// Get popular games
  Future<Either<AppException, PaginatedResponse<GameMetadata>>>
  getPopularGames({int page = 1, int pageSize = 20}) async {
    try {
      final offset = (page - 1) * pageSize;

      final igdbQuery =
          '''
        fields
          name,
          summary,
          release_dates.date,
          genres.name,
          platforms.name,
          rating,
          rating_count,
          cover.image_id;
        where rating != null & rating_count > 100;
        sort rating desc;
        limit $pageSize;
        offset $offset;
      ''';

      final response = await _dio.post('/games', data: igdbQuery);

      final items = (response.data as List)
          .map(
            (json) => GameMetadata.fromIGDBJson(json as Map<String, dynamic>),
          )
          .toList();

      final pageInfo = PageInfo(
        currentPage: page,
        pageSize: pageSize,
        totalItems: -1,
        totalPages: -1,
        hasNextPage: items.length == pageSize,
        hasPreviousPage: page > 1,
      );

      return Right(PaginatedResponse(items: items, pageInfo: pageInfo));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e, stackTrace) {
      return Left(
        AppException.unknown(
          message: 'Failed to fetch popular games: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get upcoming games
  Future<Either<AppException, PaginatedResponse<GameMetadata>>>
  getUpcomingGames({int page = 1, int pageSize = 20}) async {
    try {
      final offset = (page - 1) * pageSize;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final igdbQuery =
          '''
        fields
          name,
          summary,
          release_dates.date,
          genres.name,
          platforms.name,
          rating,
          cover.image_id;
        where release_dates.date > $now;
        sort release_dates.date asc;
        limit $pageSize;
        offset $offset;
      ''';

      final response = await _dio.post('/games', data: igdbQuery);

      final items = (response.data as List)
          .map(
            (json) => GameMetadata.fromIGDBJson(json as Map<String, dynamic>),
          )
          .toList();

      final pageInfo = PageInfo(
        currentPage: page,
        pageSize: pageSize,
        totalItems: -1,
        totalPages: -1,
        hasNextPage: items.length == pageSize,
        hasPreviousPage: page > 1,
      );

      return Right(PaginatedResponse(items: items, pageInfo: pageInfo));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e, stackTrace) {
      return Left(
        AppException.unknown(
          message: 'Failed to fetch upcoming games: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  // Helper methods
  String _buildSearchQuery({
    required String query,
    required int offset,
    required int limit,
    String? platforms,
    int? yearFrom,
    int? yearTo,
  }) {
    final filters = <String>[];

    if (platforms != null) {
      filters.add('platforms = ($platforms)');
    }

    if (yearFrom != null) {
      final timestamp = DateTime(yearFrom).millisecondsSinceEpoch ~/ 1000;
      filters.add('release_dates.date >= $timestamp');
    }

    if (yearTo != null) {
      final timestamp = DateTime(yearTo, 12, 31).millisecondsSinceEpoch ~/ 1000;
      filters.add('release_dates.date <= $timestamp');
    }

    final whereClause = filters.isNotEmpty
        ? 'where ${filters.join(' & ')};'
        : '';

    return '''
      search "$query";
      fields
        name,
        alternative_names.name,
        summary,
        storyline,
        release_dates.date,
        genres.name,
        platforms.name,
        game_modes.name,
        involved_companies.company.name,
        involved_companies.developer,
        involved_companies.publisher,
        rating,
        rating_count,
        cover.image_id,
        screenshots.image_id,
        url;
      $whereClause
      limit $limit;
      offset $offset;
    ''';
  }

  AppException _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const AppException.timeout(
        message: 'Request timeout. Please try again.',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return const AppException.network(
        message: 'Connection error. Please check your internet connection.',
      );
    }

    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return const AppException.validation(
            message: 'Invalid request parameters',
          );
        case 401:
          return const AppException.business(
            message: 'Invalid access token',
            code: 'INVALID_TOKEN',
          );
        case 429:
          return const AppException.business(
            message: 'Too many requests. Please try again later.',
            code: 'RATE_LIMIT',
          );
        case 500:
        case 502:
        case 503:
          return const AppException.network(
            message: 'Server error. Please try again later.',
          );
      }
    }

    return AppException.network(
      message: 'Network error: ${e.message ?? "Unknown error"}',
      details: e.toString(),
    );
  }
}

/// Helper class for IGDB OAuth authentication
class IGDBAuth {
  static const _tokenUrl = 'https://id.twitch.tv/oauth2/token';

  /// Get access token from Twitch
  ///
  /// You need to register your app at https://dev.twitch.tv/console/apps
  static Future<Either<AppException, String>> getAccessToken({
    required String clientId,
    required String clientSecret,
    Dio? dio,
  }) async {
    final client = dio ?? Dio();

    try {
      final response = await client.post(
        _tokenUrl,
        queryParameters: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'grant_type': 'client_credentials',
        },
      );

      final accessToken = response.data['access_token'] as String?;

      if (accessToken == null) {
        return const Left(
          AppException.business(
            message: 'Failed to get access token',
            code: 'AUTH_FAILED',
          ),
        );
      }

      return Right(accessToken);
    } on DioException catch (e) {
      return Left(
        AppException.network(
          message: 'Failed to authenticate: ${e.message ?? "Unknown error"}',
        ),
      );
    }
  }
}
