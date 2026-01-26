import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:fpdart/fpdart.dart';

import '../models/movie_metadata.dart';
import '../pagination/page_info.dart';
import '../pagination/paginated_response.dart';

/// Client for TMDB (The Movie Database) API
/// API Documentation: https://developers.themoviedb.org/3
class TMDBClient {
  TMDBClient({required String apiKey, Dio? dio})
    : _apiKey = apiKey,
      _dio = dio != null
          ? _applyBaseUrl(dio, apiKey)
          : _createDefaultDio(apiKey);

  static Dio _applyBaseUrl(Dio dio, String apiKey) {
    dio.options.baseUrl = _baseUrl;
    dio.options.headers['Authorization'] = 'Bearer $apiKey';
    return dio;
  }

  static const _baseUrl = 'https://api.themoviedb.org/3';

  final Dio _dio;
  // ignore: unused_field
  final String _apiKey;

  static Dio _createDefaultDio(String apiKey) {
    return Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      ),
    );
  }

  /// Search movies by query with pagination
  ///
  /// Example:
  /// ```dart
  /// final result = await client.searchMovies(
  ///   query: 'inception',
  ///   page: 1,
  /// );
  /// ```
  Future<Either<AppException, PaginatedResponse<MovieMetadata>>> searchMovies({
    required String query,
    int page = 1,
    String? language,
    int? year,
    bool includeAdult = false,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return Left(
          AppException.validation(message: 'Search query cannot be empty'),
        );
      }

      final queryParams = <String, dynamic>{
        // 'api_key': _apiKey,
        'query': query,
        'page': page,
        'include_adult': includeAdult,
        if (language != null) 'language': language,
        if (year != null) 'year': year,
      };

      final response = await _dio.get(
        '/search/movie',
        queryParameters: queryParams,
      );

      return Right(_parseMoviesResponse(response.data));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e, stackTrace) {
      return Left(
        AppException.unknown(
          message: 'Failed to search movies: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get movie by ID
  Future<Either<AppException, MovieMetadata>> getMovieById(
    String movieId, {
    String? language,
  }) async {
    try {
      if (movieId.trim().isEmpty) {
        return Left(
          AppException.validation(message: 'Movie ID cannot be empty'),
        );
      }

      final queryParams = <String, dynamic>{
        // 'api_key': _apiKey,
        if (language != null) 'language': language,
      };

      final response = await _dio.get(
        '/movie/$movieId',
        queryParameters: queryParams,
      );

      final metadata = MovieMetadata.fromTMDBJson(
        response.data as Map<String, dynamic>,
      );

      return Right(metadata);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(
          AppException.notFound(
            message: 'Movie not found',
            resourceType: 'Movie',
            resourceId: movieId,
          ),
        );
      }
      return Left(_handleDioException(e));
    } catch (e, stackTrace) {
      return Left(
        AppException.unknown(
          message: 'Failed to fetch movie: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get movie by IMDB ID
  Future<Either<AppException, MovieMetadata?>> getMovieByImdbId(
    String imdbId, {
    String? language,
  }) async {
    try {
      if (imdbId.trim().isEmpty) {
        return Left(
          AppException.validation(message: 'IMDB ID cannot be empty'),
        );
      }

      // Ensure IMDB ID format
      final cleanImdbId = imdbId.startsWith('tt') ? imdbId : 'tt$imdbId';

      final queryParams = <String, dynamic>{
        // 'api_key': _apiKey,
        'external_source': 'imdb_id',
        if (language != null) 'language': language,
      };

      final response = await _dio.get(
        '/find/$cleanImdbId',
        queryParameters: queryParams,
      );

      final movieResults = response.data['movie_results'] as List?;

      if (movieResults == null || movieResults.isEmpty) {
        return const Right(null);
      }

      final metadata = MovieMetadata.fromTMDBJson(
        movieResults.first as Map<String, dynamic>,
      );

      return Right(metadata);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e, stackTrace) {
      return Left(
        AppException.unknown(
          message: 'Failed to fetch movie by IMDB ID: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get popular movies
  Future<Either<AppException, PaginatedResponse<MovieMetadata>>>
  getPopularMovies({int page = 1, String? language}) async {
    try {
      final queryParams = <String, dynamic>{
        // 'api_key': _apiKey,
        'page': page,
        if (language != null) 'language': language,
      };

      final response = await _dio.get(
        '/movie/popular',
        queryParameters: queryParams,
      );

      return Right(_parseMoviesResponse(response.data));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e, stackTrace) {
      return Left(
        AppException.unknown(
          message: 'Failed to fetch popular movies: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get top rated movies
  Future<Either<AppException, PaginatedResponse<MovieMetadata>>>
  getTopRatedMovies({int page = 1, String? language}) async {
    try {
      final queryParams = <String, dynamic>{
        // 'api_key': _apiKey,
        'page': page,
        if (language != null) 'language': language,
      };

      final response = await _dio.get(
        '/movie/top_rated',
        queryParameters: queryParams,
      );

      return Right(_parseMoviesResponse(response.data));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e, stackTrace) {
      return Left(
        AppException.unknown(
          message: 'Failed to fetch top rated movies: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get upcoming movies
  Future<Either<AppException, PaginatedResponse<MovieMetadata>>>
  getUpcomingMovies({int page = 1, String? language}) async {
    try {
      final queryParams = <String, dynamic>{
        // 'api_key': _apiKey,
        'page': page,
        if (language != null) 'language': language,
      };

      final response = await _dio.get(
        '/movie/upcoming',
        queryParameters: queryParams,
      );

      return Right(_parseMoviesResponse(response.data));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e, stackTrace) {
      return Left(
        AppException.unknown(
          message: 'Failed to fetch upcoming movies: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get now playing movies
  Future<Either<AppException, PaginatedResponse<MovieMetadata>>>
  getNowPlayingMovies({int page = 1, String? language}) async {
    try {
      final queryParams = <String, dynamic>{
        // 'api_key': _apiKey,
        'page': page,
        if (language != null) 'language': language,
      };

      final response = await _dio.get(
        '/movie/now_playing',
        queryParameters: queryParams,
      );

      return Right(_parseMoviesResponse(response.data));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e, stackTrace) {
      return Left(
        AppException.unknown(
          message: 'Failed to fetch now playing movies: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Discover movies with filters
  Future<Either<AppException, PaginatedResponse<MovieMetadata>>>
  discoverMovies({
    int page = 1,
    String? language,
    String? sortBy, // 'popularity.desc', 'release_date.desc', etc.
    int? yearFrom,
    int? yearTo,
    List<int>? withGenres,
    double? voteAverageGte,
    int? voteCountGte,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        // 'api_key': _apiKey,
        'page': page,
        if (language != null) 'language': language,
        if (sortBy != null) 'sort_by': sortBy,
        if (yearFrom != null) 'primary_release_date.gte': '$yearFrom-01-01',
        if (yearTo != null) 'primary_release_date.lte': '$yearTo-12-31',
        if (withGenres != null && withGenres.isNotEmpty)
          'with_genres': withGenres.join(','),
        if (voteAverageGte != null) 'vote_average.gte': voteAverageGte,
        if (voteCountGte != null) 'vote_count.gte': voteCountGte,
      };

      final response = await _dio.get(
        '/discover/movie',
        queryParameters: queryParams,
      );

      return Right(_parseMoviesResponse(response.data));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e, stackTrace) {
      return Left(
        AppException.unknown(
          message: 'Failed to discover movies: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  // Helper methods
  PaginatedResponse<MovieMetadata> _parseMoviesResponse(
    Map<String, dynamic> data,
  ) {
    final results =
        (data['results'] as List?)
            ?.map(
              (json) =>
                  MovieMetadata.fromTMDBJson(json as Map<String, dynamic>),
            )
            .toList() ??
        [];

    final page = data['page'] as int? ?? 1;
    final totalPages = data['total_pages'] as int? ?? 0;
    final totalResults = data['total_results'] as int? ?? 0;

    final pageInfo = PageInfo(
      currentPage: page,
      pageSize: results.length,
      totalItems: totalResults,
      totalPages: totalPages,
      hasNextPage: page < totalPages,
      hasPreviousPage: page > 1,
    );

    return PaginatedResponse(items: results, pageInfo: pageInfo);
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
            message: 'Invalid API key',
            code: 'INVALID_API_KEY',
          );
        case 404:
          return const AppException.notFound(message: 'Resource not found');
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
