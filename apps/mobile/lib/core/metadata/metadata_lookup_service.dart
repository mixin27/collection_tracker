import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:metadata_api/metadata_api.dart';
import 'package:storage/storage.dart';

class MetadataApiConfig {
  const MetadataApiConfig({
    required this.googleBooksApiKey,
    required this.igdbClientId,
    required this.igdbClientSecret,
    required this.tmdbReadAccessToken,
  });

  final String googleBooksApiKey;
  final String igdbClientId;
  final String igdbClientSecret;
  final String tmdbReadAccessToken;

  bool get hasIgdbConfig =>
      igdbClientId.trim().isNotEmpty && igdbClientSecret.trim().isNotEmpty;

  bool get hasTmdbConfig => tmdbReadAccessToken.trim().isNotEmpty;
}

class MetadataLookupMatch {
  const MetadataLookupMatch({
    required this.metadata,
    required this.confidence,
    required this.source,
  });

  const MetadataLookupMatch.none()
    : metadata = null,
      confidence = 0,
      source = 'none';

  final MetadataBase? metadata;
  final double confidence;
  final String source;

  bool get hasMetadata => metadata != null;
}

class MetadataLookupService {
  MetadataLookupService({
    required MetadataApiConfig config,
    required SecureStorageService secureStorage,
  }) : _config = config,
       _secureStorage = secureStorage,
       _oauthDio = Dio(
         BaseOptions(
           connectTimeout: const Duration(seconds: 10),
           receiveTimeout: const Duration(seconds: 10),
           headers: const {'Accept': 'application/json'},
         ),
       );

  static const _igdbTokenStorageKey = 'metadata_igdb_access_token';
  static const _igdbTokenSkewSeconds = 120;
  static const _searchCacheTtl = Duration(minutes: 5);
  static const _barcodeCacheTtl = Duration(minutes: 10);
  static const _maxSearchCacheEntries = 120;
  static const _maxBarcodeCacheEntries = 120;

  final MetadataApiConfig _config;
  final SecureStorageService _secureStorage;
  final Dio _oauthDio;

  GoogleBooksClient? _booksClient;
  TMDBClient? _moviesClient;
  IGDBClient? _gamesClient;
  String? _gamesClientToken;
  Future<String?>? _tokenRefreshInFlight;
  final LinkedHashMap<String, _MetadataCacheEntry<List<MetadataBase>>>
  _searchCache = LinkedHashMap();
  final LinkedHashMap<String, _MetadataCacheEntry<MetadataLookupMatch>>
  _barcodeCache = LinkedHashMap();
  final Map<String, Future<List<MetadataBase>>> _searchInFlight = {};
  final Map<String, Future<MetadataLookupMatch>> _barcodeInFlight = {};

  bool supportsSearch(CollectionType collectionType) {
    return switch (collectionType) {
      CollectionType.book => true,
      CollectionType.game => _config.hasIgdbConfig,
      CollectionType.movie => _config.hasTmdbConfig,
      CollectionType.comic ||
      CollectionType.music ||
      CollectionType.custom => false,
    };
  }

  bool supportsBarcodeLookup({
    required CollectionType primaryType,
    List<CollectionType>? fallbackTypes,
  }) {
    if (supportsSearch(primaryType)) {
      return true;
    }

    final fallbackOrder = _resolveFallbackTypes(
      primaryType: primaryType,
      providedFallbackTypes: fallbackTypes,
    );
    return fallbackOrder.any(supportsSearch);
  }

  Future<List<MetadataBase>> search({
    required String query,
    required CollectionType collectionType,
    int limit = 10,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final key = _searchCacheKey(
      collectionType: collectionType,
      query: normalizedQuery,
      limit: limit,
    );
    final cached = _getSearchCache(key);
    if (cached != null) {
      return cached;
    }

    final inFlight = _searchInFlight[key];
    if (inFlight != null) {
      return inFlight;
    }

    final request = _searchInternal(
      query: normalizedQuery,
      collectionType: collectionType,
      limit: limit,
    );
    _searchInFlight[key] = request;

    try {
      final results = await request;
      _putSearchCache(key, results);
      return results;
    } finally {
      _searchInFlight.remove(key);
    }
  }

  Future<MetadataLookupMatch> findBestBarcodeMatch({
    required String barcode,
    required CollectionType primaryType,
    List<CollectionType>? fallbackTypes,
  }) async {
    final normalizedBarcode = barcode.trim();
    if (normalizedBarcode.isEmpty) {
      return const MetadataLookupMatch.none();
    }

    final fallbackOrder = _resolveFallbackTypes(
      primaryType: primaryType,
      providedFallbackTypes: fallbackTypes,
    );
    final key = _barcodeCacheKey(
      primaryType: primaryType,
      barcode: normalizedBarcode,
      fallbackTypes: fallbackOrder,
    );
    final cached = _getBarcodeCache(key);
    if (cached != null) {
      return cached;
    }

    final inFlight = _barcodeInFlight[key];
    if (inFlight != null) {
      return inFlight;
    }

    final request = _findBestBarcodeMatchInternal(
      barcode: normalizedBarcode,
      primaryType: primaryType,
      fallbackTypes: fallbackOrder,
    );
    _barcodeInFlight[key] = request;

    try {
      final result = await request;
      _putBarcodeCache(key, result);
      return result;
    } finally {
      _barcodeInFlight.remove(key);
    }
  }

  Future<List<MetadataBase>> _searchInternal({
    required String query,
    required CollectionType collectionType,
    required int limit,
  }) async {
    final results = switch (collectionType) {
      CollectionType.book => await _searchBooks(query, limit),
      CollectionType.game => await _searchGames(query, limit),
      CollectionType.movie => await _searchMovies(query, limit),
      CollectionType.comic ||
      CollectionType.music ||
      CollectionType.custom => const <MetadataBase>[],
    };

    return _filterSearchResults(
      collectionType: collectionType,
      results: results,
    );
  }

  Future<MetadataLookupMatch> _findBestBarcodeMatchInternal({
    required String barcode,
    required CollectionType primaryType,
    required List<CollectionType> fallbackTypes,
  }) async {
    final primary = await _safeFetchByBarcode(
      barcode: barcode,
      collectionType: primaryType,
    );

    if (primary != null) {
      return MetadataLookupMatch(
        metadata: primary,
        confidence: 1,
        source: primaryType.name,
      );
    }

    for (final fallbackType in fallbackTypes) {
      final fallback = await _safeFetchByBarcode(
        barcode: barcode,
        collectionType: fallbackType,
      );
      if (fallback != null) {
        return MetadataLookupMatch(
          metadata: fallback,
          confidence: 0.7,
          source: fallbackType.name,
        );
      }
    }

    return const MetadataLookupMatch.none();
  }

  Future<MetadataBase?> _safeFetchByBarcode({
    required String barcode,
    required CollectionType collectionType,
  }) async {
    try {
      return _fetchByBarcode(barcode: barcode, collectionType: collectionType);
    } catch (_) {
      return null;
    }
  }

  Future<MetadataBase?> _fetchByBarcode({
    required String barcode,
    required CollectionType collectionType,
  }) async {
    switch (collectionType) {
      case CollectionType.book:
        return _fetchBookByBarcode(barcode);
      case CollectionType.game:
        final games = _filterSearchResults(
          collectionType: CollectionType.game,
          results: await _searchGames(barcode, 1),
        );
        return games.isEmpty ? null : games.first;
      case CollectionType.movie:
        final movies = _filterSearchResults(
          collectionType: CollectionType.movie,
          results: await _searchMovies(barcode, 1),
        );
        return movies.isEmpty ? null : movies.first;
      case CollectionType.comic:
      case CollectionType.music:
      case CollectionType.custom:
        return null;
    }
  }

  Future<BookMetadata?> _fetchBookByBarcode(String barcode) async {
    final client = _resolveBooksClient();
    if (client == null) {
      return null;
    }

    if (_isValidIsbn(barcode)) {
      return _unwrapOrThrow<BookMetadata?>(await client.getBookByISBN(barcode));
    }

    final response = _unwrapOrThrow<PaginatedResponse<BookMetadata>>(
      await client.searchBooks(query: barcode, pageSize: 1),
    );
    if (response.items.isEmpty) {
      return null;
    }
    return response.items.first;
  }

  Future<List<MetadataBase>> _searchBooks(String query, int limit) async {
    final client = _resolveBooksClient();
    if (client == null) {
      return const [];
    }

    final response = _unwrapOrThrow<PaginatedResponse<BookMetadata>>(
      await client.searchBooks(query: query, pageSize: limit),
    );
    return response.items.cast<MetadataBase>();
  }

  Future<List<MetadataBase>> _searchGames(String query, int limit) async {
    try {
      return await _withGamesClient((client) async {
        final response = _unwrapOrThrow<PaginatedResponse<GameMetadata>>(
          await client.searchGames(query: query, pageSize: limit),
        );
        return response.items.cast<MetadataBase>();
      });
    } on AppException catch (error) {
      if (!_isInvalidIgdbTokenError(error)) {
        rethrow;
      }

      _gamesClient = null;
      _gamesClientToken = null;
      await _secureStorage.delete(_igdbTokenStorageKey);

      return _withGamesClient((client) async {
        final response = _unwrapOrThrow<PaginatedResponse<GameMetadata>>(
          await client.searchGames(query: query, pageSize: limit),
        );
        return response.items.cast<MetadataBase>();
      });
    }
  }

  Future<List<MetadataBase>> _searchMovies(String query, int limit) async {
    final client = _resolveMoviesClient();
    if (client == null) {
      return const [];
    }

    final response = _unwrapOrThrow<PaginatedResponse<MovieMetadata>>(
      await client.searchMovies(query: query),
    );
    return response.items.take(limit).toList().cast<MetadataBase>();
  }

  GoogleBooksClient? _resolveBooksClient() {
    _booksClient ??= GoogleBooksClient(
      apiKey: _config.googleBooksApiKey.trim().isEmpty
          ? null
          : _config.googleBooksApiKey,
    );
    return _booksClient;
  }

  TMDBClient? _resolveMoviesClient() {
    if (!_config.hasTmdbConfig) {
      return null;
    }

    _moviesClient ??= TMDBClient(apiKey: _config.tmdbReadAccessToken);
    return _moviesClient;
  }

  Future<IGDBClient?> _resolveGamesClient() async {
    if (!_config.hasIgdbConfig) {
      return null;
    }

    final token = await _resolveIgdbAccessToken();
    if (token == null || token.trim().isEmpty) {
      return null;
    }

    if (_gamesClient != null && _gamesClientToken == token) {
      return _gamesClient;
    }

    _gamesClientToken = token;
    _gamesClient = IGDBClient(
      clientId: _config.igdbClientId,
      accessToken: token,
    );
    return _gamesClient;
  }

  Future<String?> _resolveIgdbAccessToken() async {
    final cached = await _secureStorage.get<String>(_igdbTokenStorageKey);
    if (cached != null && cached.trim().isNotEmpty) {
      return cached;
    }

    final inFlight = _tokenRefreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final refreshFuture = _requestIgdbAccessToken();
    _tokenRefreshInFlight = refreshFuture;

    try {
      return await refreshFuture;
    } finally {
      _tokenRefreshInFlight = null;
    }
  }

  Future<String?> _requestIgdbAccessToken() async {
    if (!_config.hasIgdbConfig) {
      return null;
    }

    try {
      final response = await _oauthDio.post<Map<String, dynamic>>(
        'https://id.twitch.tv/oauth2/token',
        queryParameters: {
          'client_id': _config.igdbClientId,
          'client_secret': _config.igdbClientSecret,
          'grant_type': 'client_credentials',
        },
      );

      final data = response.data;
      if (data == null) {
        return null;
      }

      final token = (data['access_token'] as String?)?.trim();
      if (token == null || token.isEmpty) {
        return null;
      }

      final expiresIn = (data['expires_in'] as num?)?.toInt();
      final ttlSeconds = expiresIn == null
          ? null
          : (expiresIn - _igdbTokenSkewSeconds).clamp(
              _igdbTokenSkewSeconds,
              expiresIn,
            );

      await _secureStorage.save<String>(
        _igdbTokenStorageKey,
        token,
        ttl: ttlSeconds,
      );
      return token;
    } on DioException {
      return null;
    }
  }

  Future<T> _withGamesClient<T>(
    Future<T> Function(IGDBClient client) run,
  ) async {
    final client = await _resolveGamesClient();
    if (client == null) {
      throw AppException.business(
        message: 'IGDB metadata source is unavailable',
      );
    }
    return run(client);
  }

  T _unwrapOrThrow<T>(dynamic eitherResult) {
    return eitherResult.fold(
          (exception) => throw exception as AppException,
          (value) => value as T,
        )
        as T;
  }

  bool _isInvalidIgdbTokenError(AppException exception) {
    return exception.maybeWhen(
      business: (_, code) => code == 'INVALID_TOKEN',
      orElse: () => false,
    );
  }

  bool _isValidIsbn(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9X]'), '');
    return cleaned.length == 10 || cleaned.length == 13;
  }

  List<MetadataBase> _filterSearchResults({
    required CollectionType collectionType,
    required List<MetadataBase> results,
  }) {
    return switch (collectionType) {
      CollectionType.book => results.whereType<BookMetadata>().toList(),
      CollectionType.game => results.whereType<GameMetadata>().toList(),
      CollectionType.movie => results.whereType<MovieMetadata>().toList(),
      CollectionType.comic ||
      CollectionType.music ||
      CollectionType.custom => const <MetadataBase>[],
    };
  }

  List<CollectionType> _resolveFallbackTypes({
    required CollectionType primaryType,
    required List<CollectionType>? providedFallbackTypes,
  }) {
    final defaults = switch (primaryType) {
      CollectionType.book => const <CollectionType>[],
      CollectionType.game => const <CollectionType>[],
      CollectionType.movie => const <CollectionType>[],
      CollectionType.comic || CollectionType.music || CollectionType.custom =>
        const [CollectionType.book, CollectionType.movie, CollectionType.game],
    };

    final candidates = providedFallbackTypes ?? defaults;
    final resolved = <CollectionType>[];
    for (final type in candidates) {
      if (type == primaryType || resolved.contains(type)) {
        continue;
      }
      resolved.add(type);
    }
    return resolved;
  }

  String _searchCacheKey({
    required CollectionType collectionType,
    required String query,
    required int limit,
  }) {
    return '${collectionType.name}|${query.toLowerCase()}|$limit';
  }

  String _barcodeCacheKey({
    required CollectionType primaryType,
    required String barcode,
    required List<CollectionType> fallbackTypes,
  }) {
    final fallback = fallbackTypes.map((type) => type.name).join(',');
    return '${primaryType.name}|${barcode.toLowerCase()}|$fallback';
  }

  List<MetadataBase>? _getSearchCache(String key) {
    final entry = _searchCache.remove(key);
    if (entry == null) {
      return null;
    }
    if (entry.isExpired) {
      return null;
    }
    _searchCache[key] = entry;
    return entry.value;
  }

  MetadataLookupMatch? _getBarcodeCache(String key) {
    final entry = _barcodeCache.remove(key);
    if (entry == null) {
      return null;
    }
    if (entry.isExpired) {
      return null;
    }
    _barcodeCache[key] = entry;
    return entry.value;
  }

  void _putSearchCache(String key, List<MetadataBase> value) {
    _searchCache.remove(key);
    _searchCache[key] = _MetadataCacheEntry(
      value: List<MetadataBase>.unmodifiable(value),
      expiresAt: DateTime.now().add(_searchCacheTtl),
    );
    _trimCache(_searchCache, _maxSearchCacheEntries);
  }

  void _putBarcodeCache(String key, MetadataLookupMatch value) {
    _barcodeCache.remove(key);
    _barcodeCache[key] = _MetadataCacheEntry(
      value: value,
      expiresAt: DateTime.now().add(_barcodeCacheTtl),
    );
    _trimCache(_barcodeCache, _maxBarcodeCacheEntries);
  }

  void _trimCache<T>(
    LinkedHashMap<String, _MetadataCacheEntry<T>> cache,
    int maxEntries,
  ) {
    while (cache.length > maxEntries) {
      cache.remove(cache.keys.first);
    }
  }
}

class _MetadataCacheEntry<T> {
  const _MetadataCacheEntry({required this.value, required this.expiresAt});

  final T value;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
