import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:fpdart/fpdart.dart';

import '../models/book_metadata.dart';
import '../pagination/page_info.dart';
import '../pagination/paginated_response.dart';

/// Client for Google Books API
/// API Documentation: https://developers.google.com/books/docs/v1/using
class GoogleBooksClient {
  GoogleBooksClient({Dio? dio, String? apiKey})
    : _dio = dio != null ? _applyBaseUrl(dio) : _createDefaultDio(),
      _apiKey = apiKey;

  static Dio _applyBaseUrl(Dio dio) {
    dio.options.baseUrl = _baseUrl;
    return dio;
  }

  static const _baseUrl = 'https://www.googleapis.com/books/v1';

  final Dio _dio;
  final String? _apiKey;

  static Dio _createDefaultDio() {
    return Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );
  }

  /// Search books by query with pagination
  ///
  /// Example:
  /// ```dart
  /// final result = await client.searchBooks(
  ///   query: 'flutter',
  ///   page: 1,
  ///   pageSize: 20,
  /// );
  /// ```
  Future<Either<AppException, PaginatedResponse<BookMetadata>>> searchBooks({
    required String query,
    int page = 1,
    int pageSize = 20,
    String? langRestrict,
    String? orderBy, // 'relevance' or 'newest'
  }) async {
    try {
      if (query.trim().isEmpty) {
        return Left(
          AppException.validation(message: 'Search query cannot be empty'),
        );
      }

      final startIndex = (page - 1) * pageSize;

      final queryParams = <String, dynamic>{
        'q': query,
        'startIndex': startIndex,
        'maxResults': pageSize,
        'printType': 'books',
        if (_apiKey != null) 'key': _apiKey,
        if (langRestrict != null) 'langRestrict': langRestrict,
        if (orderBy != null) 'orderBy': orderBy,
      };

      final response = await _dio.get('/volumes', queryParameters: queryParams);

      return Right(_parseBooksResponse(response.data, page, pageSize));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e, stackTrace) {
      return Left(
        AppException.unknown(
          message: 'Failed to search books: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get book by ISBN
  ///
  /// Example:
  /// ```dart
  /// final result = await client.getBookByISBN('9780134685991');
  /// ```
  Future<Either<AppException, BookMetadata?>> getBookByISBN(String isbn) async {
    try {
      if (isbn.trim().isEmpty) {
        return Left(AppException.validation(message: 'ISBN cannot be empty'));
      }

      // Clean ISBN (remove hyphens, spaces)
      final cleanIsbn = isbn.replaceAll(RegExp(r'[^0-9X]'), '');

      if (cleanIsbn.length != 10 && cleanIsbn.length != 13) {
        return Left(AppException.validation(message: 'Invalid ISBN format'));
      }

      final queryParams = <String, dynamic>{
        'q': 'isbn:$cleanIsbn',
        if (_apiKey != null) 'key': _apiKey,
      };

      final response = await _dio.get('/volumes', queryParameters: queryParams);

      final items = response.data['items'] as List?;

      if (items == null || items.isEmpty) {
        return const Right(null);
      }

      final metadata = BookMetadata.fromGoogleBooksJson(
        items.first as Map<String, dynamic>,
      );

      return Right(metadata);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e, stackTrace) {
      return Left(
        AppException.unknown(
          message: 'Failed to fetch book by ISBN: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get book by ID
  Future<Either<AppException, BookMetadata>> getBookById(String bookId) async {
    try {
      if (bookId.trim().isEmpty) {
        return Left(
          AppException.validation(message: 'Book ID cannot be empty'),
        );
      }

      final queryParams = <String, dynamic>{
        if (_apiKey != null) 'key': _apiKey,
      };

      final response = await _dio.get(
        '/volumes/$bookId',
        queryParameters: queryParams,
      );

      final metadata = BookMetadata.fromGoogleBooksJson(
        response.data as Map<String, dynamic>,
      );

      return Right(metadata);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(
          AppException.notFound(
            message: 'Book not found',
            resourceType: 'Book',
            resourceId: bookId,
          ),
        );
      }
      return Left(_handleDioException(e));
    } catch (e, stackTrace) {
      return Left(
        AppException.unknown(
          message: 'Failed to fetch book: ${e.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Search books by author
  Future<Either<AppException, PaginatedResponse<BookMetadata>>> searchByAuthor({
    required String author,
    int page = 1,
    int pageSize = 20,
  }) async {
    return searchBooks(
      query: 'inauthor:$author',
      page: page,
      pageSize: pageSize,
    );
  }

  /// Search books by title
  Future<Either<AppException, PaginatedResponse<BookMetadata>>> searchByTitle({
    required String title,
    int page = 1,
    int pageSize = 20,
  }) async {
    return searchBooks(query: 'intitle:$title', page: page, pageSize: pageSize);
  }

  /// Search books by subject/category
  Future<Either<AppException, PaginatedResponse<BookMetadata>>>
  searchBySubject({
    required String subject,
    int page = 1,
    int pageSize = 20,
  }) async {
    return searchBooks(
      query: 'subject:$subject',
      page: page,
      pageSize: pageSize,
    );
  }

  // Helper methods
  PaginatedResponse<BookMetadata> _parseBooksResponse(
    Map<String, dynamic> data,
    int page,
    int pageSize,
  ) {
    final totalItems = data['totalItems'] as int? ?? 0;
    final items =
        (data['items'] as List?)
            ?.map(
              (json) => BookMetadata.fromGoogleBooksJson(
                json as Map<String, dynamic>,
              ),
            )
            .toList() ??
        [];

    final pageInfo = PageInfo(
      currentPage: page,
      pageSize: pageSize,
      totalItems: totalItems,
      totalPages: totalItems > 0 ? (totalItems / pageSize).ceil() : 0,
      hasNextPage: (page * pageSize) < totalItems,
      hasPreviousPage: page > 1,
    );

    return PaginatedResponse(items: items, pageInfo: pageInfo);
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
        case 403:
          return const AppException.business(
            message: 'API quota exceeded',
            code: 'QUOTA_EXCEEDED',
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
