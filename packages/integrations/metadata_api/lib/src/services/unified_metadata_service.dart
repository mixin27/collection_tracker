import 'package:domain/domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:metadata_api/metadata_api.dart';

/// Unified service for fetching metadata from different sources
/// based on collection type and barcode/search query
class UnifiedMetadataService {
  UnifiedMetadataService({
    GoogleBooksClient? booksClient,
    IGDBClient? gamesClient,
    TMDBClient? moviesClient,
  }) : _booksClient = booksClient,
       _gamesClient = gamesClient,
       _moviesClient = moviesClient;

  final GoogleBooksClient? _booksClient;
  final IGDBClient? _gamesClient;
  final TMDBClient? _moviesClient;

  /// Fetch metadata by barcode based on collection type
  ///
  /// Returns metadata if found, null if not found
  Future<Either<AppException, MetadataBase?>> fetchByBarcode({
    required String barcode,
    required CollectionType collectionType,
  }) async {
    switch (collectionType) {
      case CollectionType.book:
        if (_booksClient == null) return const Right(null);
        return _fetchBookByBarcode(barcode);

      case CollectionType.game:
        if (_gamesClient == null) return const Right(null);
        // IGDB doesn't support direct barcode lookup
        // You might need a barcode-to-game database or UPC lookup service
        return const Right(null);

      case CollectionType.movie:
        // TMDB doesn't support direct barcode lookup
        // You might need a UPC-to-movie database
        return const Right(null);

      case CollectionType.comic:
      case CollectionType.music:
      case CollectionType.custom:
        return const Right(null);
    }
  }

  /// Search metadata by query based on collection type
  Future<Either<AppException, List<MetadataBase>>> search({
    required String query,
    required CollectionType collectionType,
    int limit = 10,
  }) async {
    switch (collectionType) {
      case CollectionType.book:
        if (_booksClient == null) return const Right([]);
        return _searchBooks(query, limit);

      case CollectionType.game:
        if (_gamesClient == null) return const Right([]);
        return _searchGames(query, limit);

      case CollectionType.movie:
        if (_moviesClient == null) return const Right([]);
        return _searchMovies(query, limit);

      case CollectionType.comic:
      case CollectionType.music:
      case CollectionType.custom:
        return const Right([]);
    }
  }

  /// Get metadata by ID
  Future<Either<AppException, MetadataBase>> getById({
    required String id,
    required CollectionType collectionType,
  }) async {
    switch (collectionType) {
      case CollectionType.book:
        if (_booksClient == null) {
          return Left(
            AppException.business(message: 'Google Books client not available'),
          );
        }
        return (await _booksClient.getBookById(
          id,
        )).map((book) => book as MetadataBase);

      case CollectionType.game:
        if (_gamesClient == null) {
          return Left(
            AppException.business(message: 'IGDB client not available'),
          );
        }
        return (await _gamesClient.getGameById(
          id,
        )).map((game) => game as MetadataBase);

      case CollectionType.movie:
        if (_moviesClient == null) {
          return Left(
            AppException.business(message: 'TMDB client not available'),
          );
        }
        return (await _moviesClient.getMovieById(
          id,
        )).map((movie) => movie as MetadataBase);

      case CollectionType.comic:
      case CollectionType.music:
      case CollectionType.custom:
        return Left(
          AppException.notFound(
            message: 'Metadata not supported for custom collections',
          ),
        );
    }
  }

  // Private helper methods
  Future<Either<AppException, BookMetadata?>> _fetchBookByBarcode(
    String barcode,
  ) async {
    // Try as ISBN first
    if (_isValidISBN(barcode)) {
      return _booksClient!.getBookByISBN(barcode);
    }

    // If not ISBN, try searching by barcode
    // (This is less reliable)
    final searchResult = await _booksClient!.searchBooks(
      query: barcode,
      pageSize: 1,
    );

    return searchResult.map((response) {
      return response.items.isEmpty ? null : response.items.first;
    });
  }

  Future<Either<AppException, List<MetadataBase>>> _searchBooks(
    String query,
    int limit,
  ) async {
    final result = await _booksClient!.searchBooks(
      query: query,
      pageSize: limit,
    );

    return result.map((response) => response.items.cast<MetadataBase>());
  }

  Future<Either<AppException, List<MetadataBase>>> _searchGames(
    String query,
    int limit,
  ) async {
    final result = await _gamesClient!.searchGames(
      query: query,
      pageSize: limit,
    );

    return result.map((response) => response.items.cast<MetadataBase>());
  }

  Future<Either<AppException, List<MetadataBase>>> _searchMovies(
    String query,
    int limit,
  ) async {
    final result = await _moviesClient!.searchMovies(query: query);

    return result.map(
      (response) => response.items.take(limit).toList().cast<MetadataBase>(),
    );
  }

  bool _isValidISBN(String barcode) {
    final cleaned = barcode.replaceAll(RegExp(r'[^0-9X]'), '');
    return cleaned.length == 10 || cleaned.length == 13;
  }
}
